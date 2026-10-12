require("items.appearance")
require("items.apple")
require("items.menus")
-- Workspace indicators. Rift keeps its own virtual workspaces; anything else
-- uses macOS Spaces. Decided once at load, so ~/.local/bin/wm reloads the bar
-- whenever it switches window manager.
if os.execute("pgrep -x rift >/dev/null 2>&1") then
  require("items.rift")
else
  require("items.spaces")
end
require("items.spaces_indicator")
require("items.front_app")
require("items.prayer")
require("items.calendar")
require("items.widgets")
require("items.media")
