local colors = require("colors")
local settings = require("settings")

-- A button for Vorssaint's menu bar icon, which sits behind the bar. It shows
-- Vorssaint's app icon (the app font has none) and clicks the real menu bar
-- icon through Accessibility, so Vorssaint opens its own panel. Mirroring the
-- icon as an alias would need Screen Recording for SketchyBar; this does not.

local BUNDLE_ID = "com.vorssaint.utils"

local vorssaint = sbar.add("item", "widgets.vorssaint", {
  position = "right",
  width = 34,
  icon = { drawing = false },
  label = { drawing = false },
  background = {
    color = colors.bg1,
    image = {
      string = "app." .. BUNDLE_ID,
      scale = 0.7,
    },
  },
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -b " .. BUNDLE_ID,
})

sbar.add("item", "widgets.vorssaint.padding", {
  position = "right",
  width = settings.group_paddings,
})

return vorssaint
