local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Workspace indicators for rift. Rift keeps its own virtual workspaces rather
-- than macOS Spaces, so the stock "space" items in items/spaces.lua never see
-- them. These look the same and are fed by rift instead: rift's run_on_start
-- (in ~/.config/rift/config.toml) triggers the two events below, and each one
-- re-reads the whole workspace list rather than patching state piecemeal.

local RIFT_CLI = "/opt/homebrew/bin/rift-cli"
local MAX = 9 -- default_workspace_count in ~/.config/rift/config.toml

sbar.add("event", "rift_workspace_changed")
sbar.add("event", "rift_windows_changed")

local spaces, brackets, paddings = {}, {}, {}

for i = 1, MAX do
  -- Named space.N so the menus swap in items/menus.lua hides and shows these
  -- along with everything else matching /space\..*/.
  local space = sbar.add("item", "space." .. i, {
    drawing = false,
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
  })

  -- Single item bracket for space items to achieve double border on highlight
  brackets[i] = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2,
    },
  })

  paddings[i] = sbar.add("item", "space.padding." .. i, {
    drawing = false,
    width = settings.group_paddings,
  })

  space:subscribe("mouse.clicked", function(_)
    sbar.exec(RIFT_CLI .. " execute workspace switch " .. (i - 1))
  end)

  spaces[i] = space
end

local function render()
  sbar.exec(RIFT_CLI .. " query workspaces", function(workspaces)
    -- SbarLua hands back a table when the output is JSON. Anything else means
    -- rift is not answering; leave the bar as it is rather than blanking it.
    if type(workspaces) ~= "table" then return end

    local shown = {}
    for _, ws in ipairs(workspaces) do
      local i = (ws.index or -1) + 1
      if spaces[i] then
        -- One icon per app, like the macOS Spaces widget.
        local icon_line, seen = "", {}
        for _, win in ipairs(ws.windows or {}) do
          local app = win.app_name or ""
          if not seen[app] then
            seen[app] = true
            icon_line = icon_line .. (app_icons[app] or app_icons["Default"])
          end
        end

        -- Only workspaces with windows, plus the active one even if empty.
        local selected = ws.is_active == true
        local visible = selected or #(ws.windows or {}) > 0
        shown[i] = visible

        spaces[i]:set({
          drawing = visible,
          icon = { string = ws.name or tostring(i), highlight = selected },
          label = { string = icon_line ~= "" and icon_line or " —", highlight = selected },
          background = { border_color = selected and colors.black or colors.bg2 },
        })
        brackets[i]:set({
          background = { border_color = selected and colors.grey or colors.bg2 },
        })
      end
    end

    for i = 1, MAX do
      paddings[i]:set({ drawing = shown[i] == true })
      if not shown[i] then spaces[i]:set({ drawing = false }) end
    end
  end)
end

local observer = sbar.add("item", { drawing = false, updates = true })

observer:subscribe({
  "rift_workspace_changed",
  "rift_windows_changed",
  "front_app_switched",
  "system_woke",
}, render)

render()
