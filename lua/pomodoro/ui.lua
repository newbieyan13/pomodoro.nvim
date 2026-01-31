local state = require("pomodoro.state")
local config = require("pomodoro.config")

local M = {}

---@type any|nil
local popup = nil

---@type fun()|nil
local unsubscribe = nil

---Format time as MM:SS
---@param seconds number
---@return string
local function format_time(seconds)
  local mins = math.floor(seconds / 60)
  local secs = seconds % 60
  return string.format("%02d:%02d", mins, secs)
end

---Get icon for status
---@param status PomodoroStatus
---@return string
local function get_icon(status)
  local cfg = config.get()
  if status == "work" then
    return cfg.statusline.icon_work
  elseif status == "short_break" or status == "long_break" then
    return cfg.statusline.icon_break
  elseif status == "paused" then
    return cfg.statusline.icon_paused
  end
  return ""
end

---Get label for status
---@param status PomodoroStatus
---@return string
local function get_label(status)
  local cfg = config.get()
  if status == "work" then
    return cfg.statusline.label_work
  elseif status == "short_break" or status == "long_break" then
    return cfg.statusline.label_break
  elseif status == "paused" then
    return cfg.statusline.label_paused
  end
  return "IDLE"
end

---Generate popup content (ultra-minimal design)
---@return string[]
local function generate_content()
  local current = state.get()
  local cfg = config.get()

  local lines = {}

  -- First line: Icon + Label
  local icon = get_icon(current.status)
  local label = get_label(current.status)
  table.insert(lines, string.format("%s %s", icon, label))

  if current.status ~= "idle" then
    -- Second line: Time
    table.insert(lines, format_time(current.time_remaining))

    -- Third line: Progress bar
    if current.time_total > 0 then
      local progress = math.floor((1 - current.time_remaining / current.time_total) * 100)
      local bar_width = 10
      local filled = math.floor(bar_width * progress / 100)
      local bar = string.rep("█", filled) .. string.rep("░", bar_width - filled)
      table.insert(lines, string.format("%s %d%%", bar, progress))
    end

    table.insert(lines, "")

    -- Fourth line: Sessions and productivity
    local hours = string.format("%.1fh", (current.sessions_completed * cfg.durations.work) / 3600)
    table.insert(lines, string.format("%d 🍅 | %s", current.sessions_completed, hours))
  else
    table.insert(lines, "")
    table.insert(lines, "Not running")
  end

  return lines
end

---Update popup content
local function update_content()
  if not popup then
    return
  end

  local bufnr = popup.bufnr
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.bo[bufnr].modifiable = true
  local lines = generate_content()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
end

---Close popup
function M.close()
  if unsubscribe then
    unsubscribe()
    unsubscribe = nil
  end

  if popup then
    popup:unmount()
    popup = nil
  end
end

---Show statistics popup (bottom-right, minimal)
function M.show()
  if popup then
    M.close()
  end

  local ok, Popup = pcall(require, "nui.popup")
  if not ok then
    vim.notify("nui.nvim is required for Pomodoro UI", vim.log.levels.ERROR)
    return
  end

  popup = Popup({
    enter = false,
    focusable = false,
    border = {
      style = "rounded",
      text = {
        top = " 🍅 ",
        top_align = "center",
      },
    },
    position = {
      row = "100%",
      col = "100%",
    },
    size = {
      width = 18,
      height = 6,
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  popup:mount()

  update_content()

  popup:map("n", "q", function()
    M.close()
  end, { noremap = true, silent = true })

  popup:map("n", "<Esc>", function()
    M.close()
  end, { noremap = true, silent = true })

  unsubscribe = state.subscribe(function()
    vim.schedule(function()
      update_content()
    end)
  end)
end

---Toggle popup
function M.toggle()
  if popup then
    M.close()
  else
    M.show()
  end
end

return M
