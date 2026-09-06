local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("graph", "widgets.cpu" , 42, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu },
  label = {
    string = "cpu ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", background = { border_width = 5, border_color = colors.black } }
})

cpu:subscribe("cpu_update", function(env)
  -- Also available: env.user_load, env.sys_load
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })

  local color = colors.blue
  if load > 30 then
    if load < 60 then
      color = colors.yellow
    elseif load < 80 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  cpu:set({
    graph = { color = color },
    label = "cpu " .. env.total_load .. "%",
  })
end)

-- ── hover popup: top processes by CPU ──────────────────────────────
local POPUP_WIDTH = 260
local MONO = "JetBrainsMono Nerd Font Mono"
local PROC_SLOTS = 5

local cpu_header = sbar.add("item", {
  position = "popup." .. cpu.name,
  width = POPUP_WIDTH,
  align = "center",
  icon = { drawing = false },
  label = {
    string = "top processes",
    color = colors.blue,
    font = { family = MONO, style = settings.font.style_map["Bold"], size = 12.0 },
  },
})

local procs = {}
for i = 1, PROC_SLOTS do
  procs[i] = sbar.add("item", {
    position = "popup." .. cpu.name,
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

local function hide_cpu_popup()
  cpu:set({ popup = { drawing = false } })
end

local function show_cpu_popup()
  sbar.exec("ps -Aceo pcpu,comm -r | head -n " .. (PROC_SLOTS + 1) .. " | tail -n +2", function(out)
    local i = 0
    for raw in (out or ""):gmatch("[^\r\n]+") do
      local pct, name = raw:match("^%s*([%d%.]+)%s+(.+)$")
      if pct and i < PROC_SLOTS then
        i = i + 1
        procs[i]:set({
          label = { string = string.format("%5s%%  %s", pct, name:sub(1, 20)) },
          drawing = true,
        })
      end
    end
    for j = i + 1, PROC_SLOTS do procs[j]:set({ drawing = false }) end
  end)
  cpu:set({ popup = { drawing = true } })
end

cpu:subscribe("mouse.entered", show_cpu_popup)
cpu:subscribe("mouse.exited", hide_cpu_popup)
cpu:subscribe("mouse.exited.global", hide_cpu_popup)
cpu:subscribe("mouse.clicked", function()
  hide_cpu_popup()
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color = colors.bg1 }
})

-- Background around the cpu item
sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})
