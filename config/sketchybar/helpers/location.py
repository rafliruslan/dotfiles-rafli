#!/usr/bin/env python3
"""Shared location for the SketchyBar prayer and weather widgets.

macOS Location Services via CoreLocationCLI. A fix takes a second or two, so
one is taken at most every TTL and cached. Travelling is caught two ways: the
widgets force a fix on wake and on network change, and a system timezone that
no longer matches the cached fix means we have certainly moved, so the cache is
abandoned on the spot.

A denied permission, a missing binary or a slow fix falls back to the last
known good position. If there has never been one, this returns None rather
than inventing a place: widgets say they do not know where they are, which is
true, instead of quietly showing times for somewhere you are not.

Run directly to see what it currently resolves to.
"""
import json, os, subprocess, time

CLI = "/opt/homebrew/bin/CoreLocationCLI"
TTL = 900             # seconds between fixes
TIMEOUT = 15          # a fix takes 1-3s; give up long before it matters
GRID = 2              # decimals kept: ~1 km, so jitter does not churn caches
NEAR = 0.05           # degrees (~5 km) counted as "the same place"
NAME_MAX = 30         # characters the popup footer can show comfortably
CACHE = os.path.expanduser("~/.cache/sketchybar-location.json")



def _system_tz():
    """The zone macOS itself is on, which it updates as you travel."""
    try:
        return os.readlink("/etc/localtime").split("zoneinfo/")[-1]
    except Exception:
        return None


def _load():
    try:
        with open(CACHE) as f:
            c = json.load(f)
        return c if {"lat", "lon", "at"} <= c.keys() else None
    except Exception:
        return None


def _save(fix):
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    tmp = CACHE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(fix, f)
    os.replace(tmp, CACHE)


def _name(d):
    """Most specific place first, province last, the middle only if it fits."""
    fine = d.get("subLocality") or d.get("locality")
    mid = d.get("locality") if d.get("subLocality") else None
    parts, seen = [], set()
    for p in (fine, mid, d.get("administrativeArea")):
        if p and p not in seen:
            seen.add(p)
            parts.append(p)
    full = ", ".join(parts)
    if len(full) <= NAME_MAX or len(parts) < 3:
        return full
    return f"{parts[0]}, {parts[-1]}"


def _fix(previous):
    """One reading from Location Services, or None if unavailable."""
    try:
        out = subprocess.run([CLI, "--json"], capture_output=True, text=True,
                             timeout=TIMEOUT)
    except Exception:
        return None
    if out.returncode != 0:
        return None

    try:
        d = json.loads(out.stdout.strip().splitlines()[-1])
        lat, lon = round(float(d["latitude"]), GRID), round(float(d["longitude"]), GRID)
    except Exception:
        return None

    # Reverse geocoding needs the network. Without it the name comes back empty,
    # so keep the previous one rather than showing nothing -- but only while we
    # are still near where that name was recorded.
    name = _name(d)
    if not name and previous and previous.get("place"):
        if abs(lat - previous["lat"]) < NEAR and abs(lon - previous["lon"]) < NEAR:
            name = previous["place"]

    return {"lat": lat, "lon": lon, "place": name,
            "tz": d.get("timeZone") or _system_tz(), "at": time.time()}


def current(force=False):
    """Where we are: lat, lon, place, plus how that was arrived at.

    Returns None when there is no reading and never has been. source is "gps"
    (a reading no older than TTL) or "stale" (Location Services is unreachable,
    so an older reading stands). age is the reading's age in seconds.

    Pass force=True on a signal that we may have moved -- waking up, or joining
    a different network -- to skip the TTL and read the position now.
    """
    cached = _load()

    # A system timezone that disagrees with the cached fix is proof of travel:
    # macOS only changes it when the machine has actually moved.
    sys_tz = _system_tz()
    moved = bool(cached and cached.get("tz") and sys_tz and cached["tz"] != sys_tz)

    if cached and not force and not moved and time.time() - cached["at"] < TTL:
        return dict(cached, source="gps", age=time.time() - cached["at"])

    fix = _fix(cached)
    if fix:
        _save(fix)
        return dict(fix, source="gps", age=0.0)

    if cached:
        return dict(cached, source="stale", age=time.time() - cached["at"])

    return None


def describe(loc):
    """A short, honest label for where the position came from."""
    age = loc["age"] or 0
    if age < 90:
        when = "baru saja"
    elif age < 3600:
        when = f"{int(age // 60)} mnt lalu"
    elif age < 86400:
        when = f"{int(age // 3600)} jam lalu"
    else:
        when = f"{int(age // 86400)} hari lalu"
    return f"GPS {when}"


if __name__ == "__main__":
    import sys
    loc = current(force="--force" in sys.argv)
    if not loc:
        raise SystemExit("no location: Location Services unavailable, nothing cached")
    print(f"{loc['place'] or '(no name)'}  {loc['lat']}, {loc['lon']}")
    print(f"tz={loc.get('tz')}  system={_system_tz()}")
    print(f"source={loc['source']}  ->  {describe(loc)}")
