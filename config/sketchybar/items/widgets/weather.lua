local colors = require("colors")
local settings = require("settings")

local MONO = "JetBrainsMono Nerd Font Mono"
local FONT_SIZE = 15
local POPUP_W = 240
local HELPER = "$CONFIG_DIR/helpers/weather.py"

-- Rain probability thresholds for the pickup reminder
local WARN, ALERT = 30, 60

local weather = sbar.add("item", "widgets.weather", {
  position = "right",
  icon = {
    font = { family = settings.font.text, size = 16.0 },
    color = colors.blue,
    string = "",
  },
  label = { font = { family = settings.font.numbers }, string = "--" },
  update_freq = 900,
  popup = { align = "center", background = { border_width = 5, border_color = colors.black } },
})

-- ── popup: the pickup answer first, then the hourly detail ─────────
local pickup = sbar.add("item", {
  position = "popup." .. weather.name,
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
  position = "popup." .. weather.name,
  width = POPUP_W,
  icon = { drawing = false },
  label = { string = "──────────────", color = colors.grey, font = { size = 10.0 } },
})

local hours = {}
for i = 1, 8 do
  hours[i] = sbar.add("item", {
    position = "popup." .. weather.name,
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

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
  background = { color = colors.bg1 },
})
sbar.add("item", "widgets.weather.padding", {
  position = "right",
  width = settings.group_paddings,
})

-- ── data ───────────────────────────────────────────────────────────
local function refresh(open_popup)
  sbar.exec(HELPER, function(out)
    local i = 0
    for line in (out or ""):gmatch("[^\r\n]+") do
      local kind, a, b, c, d = line:match("^(%u+)|([^|]*)|?([^|]*)|?([^|]*)|?(.*)$")
      if kind == "NOW" then
        local pct = tonumber(c) or 0
        local col = colors.blue
        if pct >= ALERT then col = colors.red
        elseif pct >= WARN then col = colors.yellow end
        weather:set({
          icon = { string = (a ~= "" and a or ""), color = col },
          label = { string = b .. "°" },
        })
        pickup:set({ label = { string = string.format("%s  %d%% rain", d, pct), color = col } })
      elseif kind == "HOUR" and i < #hours then
        i = i + 1
        local pct = tonumber(c) or 0
        local bars = math.floor(pct / 10)
        hours[i]:set({
          label = {
            string = string.format("%s  %2s°  %3d%% %s", a, b, pct, string.rep("▁", bars)),
            color = (pct >= ALERT) and colors.red or (pct >= WARN and colors.yellow or colors.white),
          },
          drawing = true,
        })
      end
    end
    for j = i + 1, #hours do hours[j]:set({ drawing = false }) end
    if open_popup then weather:set({ popup = { drawing = true } }) end
  end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, function() refresh(false) end)
weather:subscribe("mouse.entered", function() refresh(true) end)
weather:subscribe("mouse.exited", function() weather:set({ popup = { drawing = false } }) end)
weather:subscribe("mouse.exited.global", function() weather:set({ popup = { drawing = false } }) end)
