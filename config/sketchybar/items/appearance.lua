-- Watches the macOS appearance setting and reloads the bar when it flips,
-- so colors.lua re-evaluates and picks the matching GitHub HC palette.
-- Also re-runs bordersrc, which does its own light/dark detection.

local function current()
  local h = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not h then return "Dark" end
  local out = h:read("*a") or ""
  h:close()
  return out:find("Dark") and "Dark" or "Light"
end

local last = current()

-- Invisible item; exists only to get a periodic "routine" tick.
local watcher = sbar.add("item", "appearance_watcher", {
  drawing = false,
  updates = true,
  update_freq = 3,
})

watcher:subscribe({ "routine", "forced", "system_woke" }, function()
  local now = current()
  if now ~= last then
    last = now
    sbar.exec("$HOME/.config/borders/bordersrc >/dev/null 2>&1 &")
    sbar.exec("sketchybar --reload")
  end
end)
