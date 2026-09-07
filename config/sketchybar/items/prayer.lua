local colors = require("colors")
local settings = require("settings")

local MONO = "JetBrainsMono Nerd Font Mono"
local NERD = "JetBrainsMono Nerd Font"
local MOSQUE = "\u{F1827}"  -- md-mosque
local FONT_SIZE = 15
local POPUP_W = 250
local HELPER = "$CONFIG_DIR/helpers/prayer.py"

-- Minutes before the adhan at which the widget starts warning.
local WARN, ALERT = 15, 5

-- Imsak and Sunrise are informational: shown, but never counted down to.
local INFO_ROWS = { Imsak = true, Sunrise = true }

local prayer = sbar.add("item", "prayer", {
  position = "left",
  icon = {
    font = { family = NERD, size = 16.0 },
    color = colors.green,
    string = MOSQUE,
  },
  label = { font = { family = settings.font.numbers }, string = "--" },
  update_freq = 60,
  popup = { align = "center", background = { border_width = 5, border_color = colors.black } },
})

-- ── popup: hijri date, then the whole day's schedule ───────────────
local hijri = sbar.add("item", {
  position = "popup." .. prayer.name,
  width = POPUP_W,
  icon = { drawing = false },
  label = {
    font = { family = MONO, style = settings.font.style_map["Bold"], size = FONT_SIZE },
    color = colors.white,
    align = "left",
    padding_left = 10,
    string = "",
  },
})

sbar.add("item", {
  position = "popup." .. prayer.name,
  width = POPUP_W,
  icon = { drawing = false },
  label = { string = "──────────────────", color = colors.grey, font = { size = 10.0 } },
})

local rows = {}
for i = 1, 7 do
  rows[i] = sbar.add("item", {
    position = "popup." .. prayer.name,
    width = POPUP_W,
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = FONT_SIZE },
      color = colors.white,
      align = "left",
      padding_left = 10,
      string = "",
    },
    drawing = false,
  })
end

-- Footer: the place, timezone and method the times were calculated with,
-- so they can be checked against a known source at a glance.
sbar.add("item", {
  position = "popup." .. prayer.name,
  width = POPUP_W,
  icon = { drawing = false },
  label = { string = "──────────────────", color = colors.grey, font = { size = 10.0 } },
})

local meta = {}
for i = 1, 5 do
  meta[i] = sbar.add("item", {
    position = "popup." .. prayer.name,
    width = POPUP_W,
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = 11.0 },
      color = colors.grey,
      align = "left",
      padding_left = 10,
      string = "",
    },
    drawing = false,
  })
end

sbar.add("bracket", "prayer.bracket", { prayer.name }, {
  background = { color = colors.bg1 },
})
sbar.add("item", "prayer.padding", {
  position = "left",
  width = settings.group_paddings,
})

-- ── data ───────────────────────────────────────────────────────────
-- relocate skips the location cache: used on the signals that mean we may
-- have moved, since a fix costs a second or two and is wasteful on a routine tick.
local function refresh(open_popup, relocate)
  sbar.exec(HELPER .. (relocate and " --force-location" or ""), function(out)
    local i, m, now_name = 0, 0, nil

    for line in (out or ""):gmatch("[^\r\n]+") do
      local kind, a, b, c = line:match("^(%u+)|([^|]*)|?([^|]*)|?(.*)$")

      if kind == "NOW" then
        -- Within a few minutes of the adhan: say so instead of counting down.
        now_name = a
        prayer:set({
          icon = { color = colors.red },
          label = { string = a .. " · now", color = colors.red },
        })

      elseif kind == "NEXT" and not now_name then
        local mins = tonumber(c) or 0
        local col = colors.white
        if mins <= ALERT then col = colors.red
        elseif mins <= WARN then col = colors.yellow end
        prayer:set({
          icon = { color = (col == colors.white) and colors.green or col },
          label = {
            string = (a == "--") and "--"
              or string.format("%s %d:%02d", a, mins // 60, mins % 60),
            color = col,
          },
        })

      elseif kind == "HIJRI" then
        hijri:set({ label = { string = a } })

      elseif kind == "META" and m < #meta then
        m = m + 1
        meta[m]:set({ label = { string = a }, drawing = true })

      elseif kind == "DAY" and i < #rows then
        i = i + 1
        local is_next = (c == "*")
        rows[i]:set({
          label = {
            string = string.format("%-8s %s%s", a, b, is_next and "  ←" or ""),
            color = is_next and colors.green
              or (INFO_ROWS[a] and colors.grey or colors.white),
          },
          drawing = true,
        })
      end
    end

    for j = i + 1, #rows do rows[j]:set({ drawing = false }) end
    for j = m + 1, #meta do meta[j]:set({ drawing = false }) end
    if open_popup then prayer:set({ popup = { drawing = true } }) end
  end)
end

prayer:subscribe({ "routine", "forced" }, function() refresh(false) end)
prayer:subscribe({ "system_woke", "wifi_change" }, function() refresh(false, true) end)
prayer:subscribe("mouse.entered", function() refresh(true) end)
prayer:subscribe("mouse.exited", function() prayer:set({ popup = { drawing = false } }) end)
prayer:subscribe("mouse.exited.global", function() prayer:set({ popup = { drawing = false } }) end)
