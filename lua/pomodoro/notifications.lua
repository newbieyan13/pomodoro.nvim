local config = require("pomodoro.config")

local M = {}

---@class NotifyOpts
---@field title? string

---@alias NotificationEvent "work_start"|"work_end"|"break_start"|"break_end"

---@type table<NotificationEvent, vim.log.levels>
local event_levels = {
  work_start = vim.log.levels.INFO,
  work_end = vim.log.levels.INFO,
  break_start = vim.log.levels.INFO,
  break_end = vim.log.levels.WARN,
}

---@type table<NotificationEvent, string>
local event_titles = {
  work_start = "Pomodoro - Work",
  work_end = "Pomodoro - Work Complete",
  break_start = "Pomodoro - Break",
  break_end = "Pomodoro - Break Over",
}

---Show notification for event
---@param event NotificationEvent Event type: work_start, work_end, break_start, break_end
function M.show(event)
  local cfg = config.get()

  if not cfg.notifications.enabled then
    return
  end

  local notifications = cfg.notifications
  local message = notifications[event]

  if not message then
    return
  end

  local level = event_levels[event] or vim.log.levels.INFO
  local title = event_titles[event] or "Pomodoro"

  ---@type NotifyOpts
  local opts = { title = title }
  vim.notify(message, level, opts)
end

---Show error notification
---@param message string
function M.error(message)
  ---@type NotifyOpts
  local opts = { title = "Pomodoro Error" }
  vim.notify(message, vim.log.levels.ERROR, opts)
end

---Show info notification
---@param message string
function M.info(message)
  local cfg = config.get()
  if not cfg.notifications.enabled then
    return
  end
  ---@type NotifyOpts
  local opts = { title = "Pomodoro" }
  vim.notify(message, vim.log.levels.INFO, opts)
end

return M
