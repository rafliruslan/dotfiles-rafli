#!/usr/bin/env python3
"""Jadwal sholat for the SketchyBar prayer widget.

Times come from the Aladhan API using the Kemenag RI calculation method, for
wherever `location.py` says we are. A whole month is fetched at once and
cached, so the network is touched about once a month and the widget keeps
working offline.

Pass --force-location to skip the location cache (the widget does this on wake
and on network change, the two moments travel shows up).

Output is line-based for easy parsing in Lua:

    NEXT|<name>|<HH:MM>|<minutes_left>
    NOW|<name>|<HH:MM>              (only within NOW_WINDOW of the adhan)
    HIJRI|<15 Rabiul Awal 1447>
    DAY|<name>|<HH:MM>|<* if next>
    ...
    META|<line>                     (place / timezone / source footer)
"""
import json, os, sys, urllib.request
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import location

METHOD = 20                           # Kementerian Agama Republik Indonesia
TUNE = ""                             # e.g. "0,2,0,0,2,2,2,0,0" to add ihtiyati minutes
NOW_WINDOW = 10                       # minutes the bar keeps showing "· now"
CACHE = os.path.expanduser("~/.cache/sketchybar-prayer.json")

LOC = location.current(force="--force-location" in sys.argv)
if not LOC:
    # Nothing known and nothing cached. Prayer times for a guessed place are
    # worse than none, so say so.
    print("NEXT|--|--:--|0")
    print("HIJRI|lokasi tidak diketahui")
    print("META|Aktifkan Location Services")
    raise SystemExit(0)

LAT, LON = LOC["lat"], LOC["lon"]
PLACE = LOC["place"] or "Lokasi tidak dikenal"

# Cached times belong to one place and one calculation method. Changing any of
# these means the stored months are for somewhere else.
FINGERPRINT = f"{LAT},{LON},{METHOD},{TUNE}"

METHOD_LABEL = {20: "Kemenag RI"}

HIJRI_MONTHS = [
    "Muharram", "Safar", "Rabiul Awal", "Rabiul Akhir",
    "Jumadil Awal", "Jumadil Akhir", "Rajab", "Sya'ban",
    "Ramadhan", "Syawal", "Dzulqaidah", "Dzulhijjah",
]

# Display name -> Aladhan timings key. Order is the order shown in the popup.
ROWS = [
    ("Imsak", "Imsak"),
    ("Subuh", "Fajr"),
    ("Terbit", "Sunrise"),
    ("Dzuhur", "Dhuhr"),
    ("Ashar", "Asr"),
    ("Maghrib", "Maghrib"),
    ("Isya", "Isha"),
]
# Only the five fardhu are counted down to; Imsak and Terbit are informational.
FARDHU = {"Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"}

dirty = False


def read_cache():
    """(months for here, whole blob from somewhere else).

    Arriving in a new city needs a fetch, and arriving is exactly when there
    may be no network. So the previous place's months are not thrown away
    until the new ones are actually in hand.
    """
    try:
        with open(CACHE) as f:
            raw = json.load(f)
    except Exception:
        return {}, None
    if raw.get("loc") == FINGERPRINT:
        return raw.get("months", {}), None
    return {}, raw


def save_cache(months, keep):
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    blob = {
        "loc": FINGERPRINT,
        "place": PLACE,
        "months": {k: v for k, v in months.items() if k in keep},
    }
    tmp = CACHE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(blob, f)
    os.replace(tmp, CACHE)


def fetch_month(year, month):
    """One month of timings, keyed by DD-MM-YYYY."""
    url = (
        "https://api.aladhan.com/v1/calendar"
        f"?latitude={LAT}&longitude={LON}&method={METHOD}"
        f"&month={month}&year={year}"
    )
    if TUNE:
        url += f"&tune={TUNE}"
    with urllib.request.urlopen(url, timeout=12) as r:
        data = json.load(r)
    return {d["date"]["gregorian"]["date"]: d for d in data["data"]}


def day_data(months, date):
    """Timings for one date, fetching and caching its month if needed."""
    global dirty
    key = f"{date.year}-{date.month:02d}"
    if key not in months:
        months[key] = fetch_month(date.year, date.month)
        dirty = True
    return months[key].get(date.strftime("%d-%m-%Y"))


def at(day, date, aladhan_key):
    """A timings entry as a datetime on the given date. '04:49 (WITA)' -> 04:49."""
    hh, mm = day["timings"][aladhan_key].split()[0].split(":")
    return date.replace(hour=int(hh), minute=int(mm), second=0, microsecond=0)


def resolve(months):
    """(today's timings, tz, tz name, now) -- raises if the day is unavailable.

    The timezone belongs to the coordinates, not to this Mac: carrying the
    laptop to another zone must not shift the times. It arrives with the data,
    so the first lookup uses the system zone merely to pick a date, and repeats
    if the real zone disagrees about what day it is.
    """
    tz = datetime.now().astimezone().tzinfo
    api_tz, day, now = None, None, None
    for _ in range(2):
        now = datetime.now(tz)
        day = day_data(months, now.date())
        if not day:
            raise LookupError("no timings for today")
        api_tz = (day.get("meta") or {}).get("timezone")
        if not api_tz or getattr(tz, "key", None) == api_tz:
            break
        tz = ZoneInfo(api_tz)
    return day, tz, api_tz, now


def bail():
    print("NEXT|--|--:--|0")
    print("HIJRI|jadwal tidak tersedia")
    print(f"META|{PLACE}")
    print(f"META|Lokasi: {location.describe(LOC)}")
    raise SystemExit(0)


months, elsewhere = read_cache()
stale_place = None

try:
    d_today, tz, api_tz, now = resolve(months)
except Exception:
    # No times for here, and no way to get them. Rather than blank the widget,
    # stand on the previous place's schedule and say plainly that is what it is.
    if elsewhere and elsewhere.get("months"):
        months, dirty = elsewhere["months"], False
        stale_place = elsewhere.get("place") or "lokasi sebelumnya"
        try:
            d_today, tz, api_tz, now = resolve(months)
        except Exception:
            bail()
    else:
        bail()

today = now.date()
tomorrow = (now + timedelta(days=1)).date()
midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)

# Only needed after Isya, and only across a month boundary. Losing it must
# not blank the widget, so a failure here is survivable.
try:
    d_tomorrow = day_data(months, tomorrow)
except Exception:
    d_tomorrow = None

if dirty and not stale_place:
    save_cache(months, {f"{d.year}-{d.month:02d}" for d in (today, tomorrow)})

# Today's schedule, as (display name, datetime).
schedule = [(name, at(d_today, midnight, key)) for name, key in ROWS]

# The next fardhu: the first one still ahead today, else tomorrow's Subuh.
nxt = next(((n, t) for n, t in schedule if n in FARDHU and t > now), None)
if nxt is None:
    if d_tomorrow:
        nxt = ("Subuh", at(d_tomorrow, midnight + timedelta(days=1), "Fajr"))
    else:
        # No data for tomorrow: reuse today's Subuh as an estimate. It moves by
        # under a minute a day here, so the countdown stays honest.
        nxt = ("Subuh", at(d_today, midnight + timedelta(days=1), "Fajr"))

# The most recent fardhu, if the adhan was within the last few minutes.
passed = [(n, t) for n, t in schedule if n in FARDHU and t <= now]
if passed:
    name, t = passed[-1]
    if (now - t) < timedelta(minutes=NOW_WINDOW):
        print(f"NOW|{name}|{t:%H:%M}")

print(f"NEXT|{nxt[0]}|{nxt[1]:%H:%M}|{int((nxt[1] - now).total_seconds() // 60)}")

h = d_today["date"]["hijri"]
month = HIJRI_MONTHS[int(h["month"]["number"]) - 1]
print(f"HIJRI|{int(h['day'])} {month} {h['year']}")

for name, t in schedule:
    print(f"DAY|{name}|{t:%H:%M}|{'*' if name == nxt[0] else ''}")

# Footer: where these times are for and how that was decided, so they can be
# sanity checked against a known source. The clock is this script's own idea of
# the time there -- if it disagrees with the menu bar, the zone is wrong.
meta = d_today.get("meta", {})
method = METHOD_LABEL.get(METHOD) or meta.get("method", {}).get("name", "")[:20]
print(f"META|{PLACE}")
print(f"META|Timezone: {api_tz or getattr(tz, 'key', '?')} ({now:%H:%M})")
print(f"META|Lokasi: {location.describe(LOC)}")
if stale_place:
    print(f"META|! jadwal masih {stale_place}")
print(f"META|Metode {method}")
