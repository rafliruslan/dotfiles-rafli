local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	height = 40,
	color = colors.bar.bg,
	padding_right = 2,
	padding_left = 2,
	display = "all",          -- draw on every monitor, not just the main one
	sticky = "on",            -- stay visible across spaces
	topmost = "window",       -- sit above tiled windows
	notch_display_height = 0, -- built-in MBP notch: bar spans the full width
})
