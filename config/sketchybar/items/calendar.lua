local settings = require("settings")
local colors = require("colors")

local POPUP_MAX = 300
local POPUP_WIDTH = POPUP_MAX
local TEXT_PAD_L = 10
-- Grid needs FIXED advance width; settings.font.numbers is the proportional face.
local MONO = "JetBrainsMono Nerd Font Mono"
-- Grid geometry: every row needs the SAME label width and left alignment.
-- Auto-width labels get centred individually, which is what misaligned the
-- columns -- and note `align` must be set on the LABEL, not on the item.
-- cal emits exactly 20 columns. JetBrainsMono advance = 0.6 * size, so
-- 20 chars * 0.6 * SIZE = rendered width. 18.5 -> ~222px, filling the box.
local FONT_SIZE = 15                       -- calendar, events, reminders
local GRID_FONT_SIZE = FONT_SIZE
-- Auto-width overflows the screen: the longest reminder is ~44 chars.
-- Cap the popup and truncate text to what fits at FONT_SIZE.
local TEXT_LABEL_W = POPUP_MAX - 20
local TEXT_CHARS = math.floor(TEXT_LABEL_W / (0.6 * FONT_SIZE))

-- Truncate with an ellipsis. Counts UTF-8 characters, not bytes, so an
-- emoji or accented title is not cut mid-codepoint.
local function elide(str, max)
  local n, cut = 0, nil
  for i = 1, #str do
    local b = str:byte(i)
    if b < 0x80 or b >= 0xC0 then          -- start of a codepoint
      n = n + 1
      -- record the byte offset just before the character that overflows
      if n == max + 1 then cut = i - 1 end
    end
  end
  if not cut then return str end           -- short enough, leave it alone
  return (str:sub(1, cut):gsub("%s+$", "")) .. "…"
end
-- Grid box hugs the rendered text (20 * 0.6 * size), and the leftover
-- popup space is split evenly as left padding so the grid sits centred.
-- Auto-width: every grid row is exactly 23 chars in a mono face, so they
-- all measure the same and stay aligned without a fixed box.
local GRID_LABEL_W = 0
-- Spaces between the 2-char day cells. 7 cells + 6 gaps:
--   gap 1 -> 20 chars, gap 2 -> 26, gap 3 -> 32
local CELL_GAP = 3
local WEEK_START_MONDAY = true
-- 7 cells * 2 chars + 6 gaps = grid width in chars; * 0.6 * FONT_SIZE = px
local GRID_PX = math.floor((14 + 6 * CELL_GAP) * 0.6 * FONT_SIZE)
local GRID_PAD_L = math.max(6, math.floor((POPUP_MAX - GRID_PX) / 2))
local EVENT_SLOTS = 3

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = { style = settings.font.style_map["Black"], size = 12.0 },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 49,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1,
  },
  popup = {
    align = "right",
    background = { border_width = 5, border_color = colors.black },
  },
  click_script = "open -a 'Calendar'",
})

-- ── popup: month grid ──────────────────────────────────────────────
local month_header = sbar.add("item", {
  position = "popup." .. cal.name,
  width = POPUP_MAX,
  align = "center",
  icon = { drawing = false },
  label = {
    font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = FONT_SIZE },
    color = colors.blue,
  },
})

-- 7 rows: weekday header + up to 6 week rows. `cal` never emits more.
local grid = {}
for i = 1, 7 do
  grid[i] = sbar.add("item", {
    position = "popup." .. cal.name,
    width = POPUP_MAX,
    align = "left",
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = GRID_FONT_SIZE },
      color = (i == 1) and colors.grey or colors.white,
      string = "",
      align = "left",
      width = GRID_LABEL_W,
      padding_left = GRID_PAD_L,
    },
    drawing = false,
  })
end

-- ── popup: upcoming events ─────────────────────────────────────────
local divider = sbar.add("item", {
  position = "popup." .. cal.name,
  width = POPUP_MAX,
  align = "center",
  icon = { drawing = false },
  label = { string = "───────────────", color = colors.grey, font = { size = 10.0 } },
})

local events = {}
for i = 1, EVENT_SLOTS do
  events[i] = sbar.add("item", {
    position = "popup." .. cal.name,
    width = POPUP_MAX,
    align = "left",
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = FONT_SIZE },
      color = colors.white,
      align = "left",
      width = TEXT_LABEL_W,
      padding_left = TEXT_PAD_L,
      string = "",
    },
    drawing = false,
  })
end

-- ── popup: reminders (overdue first, then upcoming) ────────────────
local REMINDER_SLOTS = 4

local rem_divider = sbar.add("item", {
  position = "popup." .. cal.name,
  width = POPUP_MAX,
  align = "center",
  icon = { drawing = false },
  label = { string = "───── reminders ─────", color = colors.grey, font = { size = 10.0 } },
  drawing = false,
})

local reminders = {}
for i = 1, REMINDER_SLOTS do
  reminders[i] = sbar.add("item", {
    position = "popup." .. cal.name,
    width = POPUP_MAX,
    align = "left",
    icon = { drawing = false },
    label = {
      font = { family = MONO, size = FONT_SIZE },
      color = colors.white,
      align = "left",
      width = TEXT_LABEL_W,
      padding_left = TEXT_PAD_L,
      string = "",
    },
    drawing = false,
  })
end

sbar.add("bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_color = colors.grey,
  },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

-- ── clock ──────────────────────────────────────────────────────────
cal:subscribe({ "forced", "routine", "system_woke" }, function()
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
end)

-- ── hover ──────────────────────────────────────────────────────────
local function hide_popup()
  cal:set({ popup = { drawing = false } })
end

local function show_popup()
  month_header:set({ label = os.date("%B %Y") })

  -- Build the grid ourselves: macOS `cal` cannot start the week on Monday,
  -- and this also lets us control the spacing between day columns.
  do
    local now = os.date("*t")
    local first = os.date("*t", os.time({ year = now.year, month = now.month, day = 1 }))
    local last = os.date("*t", os.time({ year = now.year, month = now.month + 1, day = 0 }))
    local ndays = last.day

    -- os.date wday: 1=Sun .. 7=Sat. Convert to 0-based column index.
    local lead
    if WEEK_START_MONDAY then
      lead = (first.wday + 5) % 7           -- Monday -> 0
    else
      lead = first.wday - 1                 -- Sunday -> 0
    end

    local sep = string.rep(" ", CELL_GAP)
    local names = WEEK_START_MONDAY
      and { "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" }
      or  { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" }

    local rows = { table.concat(names, sep) }
    local cells, day = {}, 1
    for _ = 1, lead do cells[#cells + 1] = "  " end
    while day <= ndays do
      cells[#cells + 1] = string.format("%2d", day)
      if #cells == 7 then
        rows[#rows + 1] = table.concat(cells, sep)
        cells = {}
      end
      day = day + 1
    end
    if #cells > 0 then
      while #cells < 7 do cells[#cells + 1] = "  " end
      rows[#rows + 1] = table.concat(cells, sep)
    end

    local today = now.day
    for i = 1, 7 do
      local line = rows[i]
      if line then
        if i > 1 then
          -- bracket today in place: consume one separator space either side
          local d2 = string.format("%2d", today)
          local at = line:find(d2, 1, true)
          if at then
            local before = (at > 1) and line:sub(1, at - 2) or ""
            local after = line:sub(at + 2)
            line = before .. "[" .. d2 .. "]" .. after:sub(2)
          end
        end
        grid[i]:set({ label = { string = line }, drawing = true })
      else
        grid[i]:set({ drawing = false })
      end
    end
  end

  sbar.exec(
    "/opt/homebrew/bin/icalBuddy -n -nc -b '' -ps '|  |' -iep 'datetime,title' "
      .. "-df '' -tf '%H:%M' -li " .. EVENT_SLOTS .. " eventsToday 2>/dev/null",
    function(out)
      local i = 0
      for raw in (out or ""):gmatch("[^\r\n]+") do
        local line = raw:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" and i < EVENT_SLOTS then
          i = i + 1
          events[i]:set({ label = { string = elide(line, TEXT_CHARS) }, drawing = true })
        end
      end
      if i == 0 then
        i = 1
        events[1]:set({ label = { string = "no events today", color = colors.grey }, drawing = true })
      end
      for j = i + 1, EVENT_SLOTS do events[j]:set({ drawing = false }) end
    end
  )

  -- overdue first (red), then the rest of the open list
  sbar.exec(
    "/opt/homebrew/bin/icalBuddy -n -nc -b '' -ps '|  |' -itp 'title' -stda "
      .. "tasksDueBefore:today 2>/dev/null",
    function(over)
      local i = 0
      local seen = {}
      for raw in (over or ""):gmatch("[^\r\n]+") do
        local is_title = not raw:match("^%s")
        local line = raw:gsub("^%s*!?%s*", ""):gsub("%s+$", "")
        if is_title and line ~= "" and i < REMINDER_SLOTS then
          i = i + 1
          seen[line] = true
          reminders[i]:set({
            label = { string = "! " .. elide(line, TEXT_CHARS - 2), color = colors.red },
            drawing = true,
          })
        end
      end

      sbar.exec(
        "/opt/homebrew/bin/icalBuddy -n -nc -b '' -ps '|  |' -itp 'title' -stda "
          .. "uncompletedTasks 2>/dev/null",
        function(all)
          local j = i
          for raw in (all or ""):gmatch("[^\r\n]+") do
            local is_title = not raw:match("^%s")
            local line = raw:gsub("^%s*!?%s*", ""):gsub("%s+$", "")
            if is_title and line ~= "" and not seen[line] and j < REMINDER_SLOTS then
              j = j + 1
              reminders[j]:set({
                label = { string = "  " .. elide(line, TEXT_CHARS - 2), color = colors.white },
                drawing = true,
              })
            end
          end
          rem_divider:set({ drawing = j > 0 })
          for k = j + 1, REMINDER_SLOTS do reminders[k]:set({ drawing = false }) end
        end
      )
    end
  )

  cal:set({ popup = { drawing = true } })
end

cal:subscribe("mouse.entered", show_popup)
cal:subscribe("mouse.exited", hide_popup)
cal:subscribe("mouse.exited.global", hide_popup)
-- click always closes (and still opens Calendar via click_script)
cal:subscribe("mouse.clicked", hide_popup)
