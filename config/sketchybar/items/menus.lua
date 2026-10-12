local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local menu_watcher = sbar.add("item", {
  drawing = false,
  updates = false,
})
local space_menu_swap = sbar.add("item", {
  drawing = false,
  updates = true,
})
sbar.add("event", "swap_menus_and_spaces")
sbar.add("event", "menus_toggled")

local max_items = 15
local menu_items = {}
for i = 1, max_items, 1 do
  local menu = sbar.add("item", "menu." .. i, {
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    drawing = false,
    icon = { drawing = false },
    label = {
      font = {
        style = settings.font.style_map[i == 1 and "Heavy" or "Semibold"]
      },
      padding_left = 6,
      padding_right = 6,
    },
    click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
  })

  menu_items[i] = menu
end

sbar.add("bracket", { '/menu\\..*/' }, {
  background = { color = colors.bg1 }
})

local menu_padding = sbar.add("item", "menu.padding", {
  drawing = false,
  width = 5
})

-- Fills the menu items from the front app's menu bar, then calls on_shown if
-- any came back. An empty list (no front app, or one with no menu bar) leaves
-- the bar as it is: hiding the workspaces with nothing to put in their place
-- would leave that end of the bar blank.
local function update_menus(on_shown)
  sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
    local names = {}
    for menu in string.gmatch(menus or "", '[^\r\n]+') do
      if #names >= max_items then break end
      names[#names + 1] = menu
    end
    if #names == 0 then return end

    for i = 1, max_items do
      if names[i] then
        menu_items[i]:set({ label = names[i], drawing = true })
      else
        menu_items[i]:set({ drawing = false })
      end
    end
    menu_padding:set({ drawing = true })
    if on_shown then on_shown() end
  end)
end

local showing_menus = false

menu_watcher:subscribe("front_app_switched", function(_)
  update_menus()
end)

space_menu_swap:subscribe("swap_menus_and_spaces", function(_)
  if showing_menus then
    showing_menus = false
    menu_watcher:set({ updates = false })
    sbar.set("/menu\\..*/", { drawing = false })
    sbar.set("/space\\..*/", { drawing = true })
    sbar.set("front_app", { drawing = true })
    -- Rift hides its empty workspaces; the line above just drew all nine, so
    -- have items/rift.lua redraw them. Nothing listens to this under AeroSpace.
    sbar.trigger("rift_workspace_changed")
    sbar.trigger("menus_toggled")
  else
    update_menus(function()
      showing_menus = true
      menu_watcher:set({ updates = true })
      sbar.set("/space\\..*/", { drawing = false })
      sbar.set("front_app", { drawing = false })
      sbar.trigger("menus_toggled")
    end)
  end
end)

return menu_watcher
