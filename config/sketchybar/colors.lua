-- GitHub High Contrast, following the macOS appearance setting.
-- Palettes taken verbatim from Ghostty's shipped theme files, so the
-- terminal and the bar resolve to identical values in both modes.

local function is_dark()
  local h = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not h then return true end
  local out = h:read("*a") or ""
  h:close()
  return out:find("Dark") ~= nil
end

local dark = {
  black = 0xff0a0c10,   -- background
  white = 0xfff0f3f6,   -- foreground
  red = 0xffff9492,
  green = 0xff26cd4d,
  blue = 0xff71b7ff,
  yellow = 0xfff0b72f,
  orange = 0xffe7811d,  -- Primer dark-high-contrast "severe"
  magenta = 0xffcb9eff,
  grey = 0xff9ea7b3,
  bar_bg = 0xf00a0c10,
  bar_border = 0xff0a0c10,
  popup_bg = 0xc00a0c10,
  popup_border = 0xff9ea7b3,
  bg1 = 0xff272b33,
  bg2 = 0xff3d444d,
}

local light = {
  black = 0xffffffff,   -- background (inverted role: the bar's ground)
  white = 0xff0e1116,   -- foreground (inverted role: the bar's ink)
  red = 0xffa0111f,
  green = 0xff024c1a,
  blue = 0xff0349b4,
  yellow = 0xff3f2200,
  orange = 0xff702c00,  -- Primer light-high-contrast "severe"
  magenta = 0xff622cbc,
  grey = 0xff4b535d,
  bar_bg = 0xf0ffffff,
  bar_border = 0xffffffff,
  popup_bg = 0xc0ffffff,
  popup_border = 0xff4b535d,
  bg1 = 0xffe7ecf0,
  bg2 = 0xffced5dc,
}

local p = is_dark() and dark or light

return {
  black = p.black,
  white = p.white,
  red = p.red,
  green = p.green,
  blue = p.blue,
  yellow = p.yellow,
  orange = p.orange,
  magenta = p.magenta,
  grey = p.grey,
  transparent = 0x00000000,

  bar = { bg = p.bar_bg, border = p.bar_border },
  popup = { bg = p.popup_bg, border = p.popup_border },
  bg1 = p.bg1,
  bg2 = p.bg2,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
