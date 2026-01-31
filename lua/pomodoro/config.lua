---@class NotificationMessages
---@field work_start string
---@field work_end string
---@field break_start string
---@field break_end string

---@class NotificationConfig : NotificationMessages
---@field enabled boolean

---@class PomodoroConfig
---@field durations { work: number, short_break: number, long_break: number }
---@field sessions_until_long_break number
---@field notifications NotificationConfig
---@field ui { border_style: string, width: number, height: number }
---@field statusline { enabled: boolean, icon_work: string, icon_break: string, icon_paused: string, icon_idle: string, label_work: string, label_break: string, label_paused: string, format: string }
---@field highlights { work: table, break: table, idle: table }

local M = {}

---@type PomodoroConfig
M.defaults = {
  durations = {
    work = 25 * 60,        -- 25 minutes
    short_break = 5 * 60,  -- 5 minutes
    long_break = 15 * 60,  -- 15 minutes
  },

  sessions_until_long_break = 4,

  notifications = {
    enabled = true,
    work_start = "Let's focus! Work session started.",
    work_end = "Great work! Time for a break.",
    break_start = "Break started. Relax!",
    break_end = "Break over. Ready to work?",
  },

  ui = {
    border_style = "rounded",
    width = 50,
    height = 15,
  },

  statusline = {
    enabled = true,
    icon_work = "🍅",
    icon_break = "☕",
    icon_paused = "⏸",
    icon_idle = "",
    label_work = "WORK",
    label_break = "BREAK",
    label_paused = "PAUSED",
    format = "%s %s %02d:%02d",  -- label, icon, min, sec
  },

  highlights = {
    work = { fg = "#f38ba8", bold = true },
    ["break"] = { fg = "#a6e3a1", bold = true },
    idle = { fg = "#7f849c" },
  },
}

---@type PomodoroConfig?
M.options = nil

---Merge user options with defaults (immutable)
---@param opts? table
---@return PomodoroConfig
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
  return M.options
end

---Get current config (returns deep copy for immutability)
---@return PomodoroConfig
function M.get()
  return vim.deepcopy(M.options or M.defaults)
end

return M
