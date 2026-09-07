#!/usr/bin/env python3
"""Open-Meteo forecast for the SketchyBar weather widget.

No API key required. Output is line-based for easy parsing in Lua:

    NOW|<rain|dry>|<temp>|<pickup_pct>|<pickup_label>
    HOUR|<HH:MM>|<temp>|<pct>
    ...
    META|<line>                    (place / source footer)

Results are cached so hovering does not hit the network every time.
"""
import json, os, sys, time, urllib.request
from datetime import datetime, timedelta, timezone as _tz

import location

LOC = location.current(force="--force-location" in sys.argv)
if not LOC:
    print("NOW|dry|--|0|lokasi tidak diketahui")
    print("META|Aktifkan Location Services")
    sys.exit(0)

LAT, LON = LOC["lat"], LOC["lon"]
PICKUP_HOUR = 20                      # evening hour the popup reports rain for
HOURS_AHEAD = 8
CACHE = os.path.expanduser("~/.cache/sketchybar-weather.json")
FINGERPRINT = f"{LAT},{LON}"
CACHE_TTL = 900                       # 15 minutes
# Chance of rain this hour at which the bar switches to the rain icon. Bali's
# wet season sits high for weeks, so a coin-flip 50 would leave it raining all
# season and the cloud icon would stop meaning anything.
RAIN_AT = 60
# WMO codes from 51 up are drizzle, rain, snow, showers or thunder. Fog (45,
# 48) is not precipitation, so it stays below the line.
RAIN_CODE = 51

def fetch():
    if os.path.exists(CACHE) and time.time() - os.path.getmtime(CACHE) < CACHE_TTL:
        try:
            with open(CACHE) as f:
                cached = json.load(f)
            if cached.get("_loc") == FINGERPRINT:
                return cached
        except Exception:
            pass
    url = (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={LAT}&longitude={LON}"
        "&current=temperature_2m,weather_code"
        "&hourly=precipitation_probability,temperature_2m,weather_code"
        "&timezone=auto&forecast_days=2"
    )
    with urllib.request.urlopen(url, timeout=12) as r:
        data = json.load(r)
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    data["_loc"] = FINGERPRINT
    with open(CACHE, "w") as f:
        json.dump(data, f)
    return data

try:
    d = fetch()
except Exception as e:
    print("NOW|dry|--|0|weather unavailable")
    print(f"META|{LOC['place'] or 'Lokasi tidak dikenal'}")
    print(f"META|Lokasi: {location.describe(LOC)}")
    sys.exit(0)

cur = d["current"]
temp = round(cur["temperature_2m"])

h = d["hourly"]
now = (datetime.now(_tz.utc) + timedelta(seconds=d.get("utc_offset_seconds", 0)))
now = now.replace(tzinfo=None, minute=0, second=0, microsecond=0)
rows, pickup_pct, pickup_when = [], None, ""

for t, tp, pp in zip(h["time"], h["temperature_2m"], h["precipitation_probability"]):
    dt = datetime.fromisoformat(t)
    if dt < now:
        continue
    # the next occurrence of the pickup hour
    if pickup_pct is None and dt.hour == PICKUP_HOUR:
        pickup_pct = pp
        pickup_when = "tonight" if dt.date() == now.date() else dt.strftime("%a")
    if len(rows) < HOURS_AHEAD:
        rows.append((dt.strftime("%H:%M"), round(tp), pp))

# Raining now, or likely enough within the hour to matter.
now_pct = rows[0][2] if rows else 0
raining = cur["weather_code"] >= RAIN_CODE or now_pct >= RAIN_AT

print(f"NOW|{'rain' if raining else 'dry'}|{temp}|{pickup_pct or 0}|{PICKUP_HOUR}:00 {pickup_when}")
for hh, tp, pp in rows:
    print(f"HOUR|{hh}|{tp}|{pp}")

# Footer: which place this forecast is for, and how that was decided.
print(f"META|{LOC['place'] or 'Lokasi tidak dikenal'}")
print(f"META|Lokasi: {location.describe(LOC)}")
