local state = require("pomodoro.state")
local config = require("pomodoro.config")

local M = {}

---Format time as MM:SS
---@param seconds number
---@return number minutes
---@return number seconds
local function format_time(seconds)
  local mins = math.floor(seconds / 60)
  local secs = seconds % 60
  return mins, secs
end

---Get icon for current status
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

---Get label for current status
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
  return ""
end

---Get highlight group for current status
---@param status PomodoroStatus
---@return string
local function get_highlight(status)
  if status == "work" then
    return "PomodoroWork"
  elseif status == "short_break" or status == "long_break" then
    return "PomodoroBreak"
  elseif status == "paused" then
    return "PomodoroIdle"
  end
  return ""
end

---Generate progress bar
---@param time_remaining number
---@param time_total number
---@return string
local function get_progress_bar(time_remaining, time_total)
  if time_total == 0 then
    return ""
  end

  local progress = math.floor((1 - time_remaining / time_total) * 100)
  local bar_width = 8
  local filled = math.floor(bar_width * progress / 100)
  return string.rep("█", filled) .. string.rep("░", bar_width - filled)
end

---Get statusline component string
---@return string
function M.component()
  local current = state.get()
  local cfg = config.get()

  if not cfg.statusline.enabled then
    return ""
  end

  if current.status == "idle" then
    return ""
  end

  local label = get_label(current.status)
  local icon = get_icon(current.status)
  local mins, secs = format_time(current.time_remaining)
  local progress_bar = get_progress_bar(current.time_remaining, current.time_total)

  return string.format("%s %s %s %02d:%02d", label, icon, progress_bar, mins, secs)
end

---Get lualine component configuration
---@return table
function M.lualine_component()
  return {
    function()
      return M.component()
    end,
    cond = function()
      local current = state.get()
      return current.status ~= "idle"
    end,
    color = function()
      local current = state.get()
      local hl = get_highlight(current.status)
      if hl ~= "" then
        return hl
      end
      return nil
    end,
  }
end

return M
