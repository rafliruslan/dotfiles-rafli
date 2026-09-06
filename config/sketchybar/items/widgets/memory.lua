local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local MONO = "JetBrainsMono Nerd Font Mono"
local POPUP_WIDTH = 260
local PROC_SLOTS = 5

-- macOS reports FREE percentage; we display used = 100 - free.
local WARN, HIGH, CRIT = 60, 75, 88

local mem = sbar.add("graph", "widgets.memory", 42, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.memory or "" },
  label = {
    string = "mem ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4,
  },
  padding_right = settings.paddings + 6,
  update_freq = 5,
  popup = { align = "center", background = { border_width = 5, border_color = colors.black } },
})

-- ── hover popup: top processes by resident memory ──────────────────
local header = sbar.add("item", {
  position = "popup." .. mem.name,
  width = POPUP_WIDTH,
  align = "center",
  icon = { drawing = false },
  label = {
    string = "top memory",
    color = colors.blue,
    font = { family = MONO, style = settings.font.style_map["Bold"], size = 12.0 },
  },
})

local procs = {}
for i = 1, PROC_SLOTS do
  procs[i] = sbar.add("item", {
    position = "popup." .. mem.name,
    width = POPUP_WIDTH,
    align = "left",
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = 12.0 },
      color = colors.white,
      padding_left = 10,
      string = "",
    },
    drawing = false,
  })
end

sbar.add("bracket", "widgets.memory.bracket", { mem.name }, {
  background = { color = colors.bg1 },
})
sbar.add("item", "widgets.memory.padding", {
  position = "right",
  width = settings.group_paddings,
})

-- ── sampling ───────────────────────────────────────────────────────
mem:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec("memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ {gsub(/%/,\"\",$2); print $2}'",
    function(out)
      local free = tonumber((out or ""):match("%d+"))
      if not free then return end
      local used = 100 - free

      local color = colors.blue
      if used >= CRIT then color = colors.red
      elseif used >= HIGH then color = colors.orange
      elseif used >= WARN then color = colors.yellow end

      mem:push({ used / 100. })
      mem:set({ graph = { color = color }, label = "mem " .. used .. "%" })
    end)
end)

-- ── hover ──────────────────────────────────────────────────────────
local function hide() mem:set({ popup = { drawing = false } }) end

local function show()
  sbar.exec("ps -Aceo rss,comm -m | head -n " .. (PROC_SLOTS + 1) .. " | tail -n +2", function(out)
    local i = 0
    for raw in (out or ""):gmatch("[^\r\n]+") do
      local rss, name = raw:match("^%s*(%d+)%s+(.+)$")
      if rss and i < PROC_SLOTS then
        i = i + 1
        procs[i]:set({
          label = { string = string.format("%6.1f GB  %s", tonumber(rss) / 1048576, name:sub(1, 18)) },
          drawing = true,
        })
      end
    end
    for j = i + 1, PROC_SLOTS do procs[j]:set({ drawing = false }) end
  end)
  mem:set({ popup = { drawing = true } })
end

mem:subscribe("mouse.entered", show)
mem:subscribe("mouse.exited", hide)
mem:subscribe("mouse.exited.global", hide)
mem:subscribe("mouse.clicked", function()
  hide()
  sbar.exec("open -a 'Activity Monitor'")
end)
