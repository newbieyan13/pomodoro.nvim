local M = {}

local config = require("pomodoro.config")
local state = require("pomodoro.state")
local timer = require("pomodoro.timer")
local notifications = require("pomodoro.notifications")
local ui = require("pomodoro.ui")
local statusline = require("pomodoro.statusline")

---Setup highlight groups
local function setup_highlights()
  local cfg = config.get()

  vim.api.nvim_set_hl(0, "PomodoroWork", cfg.highlights.work)
  vim.api.nvim_set_hl(0, "PomodoroBreak", cfg.highlights["break"])
  vim.api.nvim_set_hl(0, "PomodoroIdle", cfg.highlights.idle)
end

---Setup user commands
local function setup_commands()
  vim.api.nvim_create_user_command("PomodoroStart", function(opts)
    local duration = opts.args ~= "" and tonumber(opts.args) or nil
    if duration then
      timer.start("work", duration * 60)
    else
      timer.start("work")
    end
  end, {
    desc = "Start Pomodoro work session (optional: duration in minutes)",
    nargs = "?",
  })

  vim.api.nvim_create_user_command("PomodoroStop", function()
    timer.stop()
    notifications.info("Pomodoro stopped.")
  end, { desc = "Stop Pomodoro timer" })

  vim.api.nvim_create_user_command("PomodoroPause", function()
    timer.pause()
    notifications.info("Pomodoro paused.")
  end, { desc = "Pause Pomodoro timer" })

  vim.api.nvim_create_user_command("PomodoroResume", function()
    timer.resume()
    notifications.info("Pomodoro resumed.")
  end, { desc = "Resume Pomodoro timer" })

  vim.api.nvim_create_user_command("PomodoroToggle", function()
    ui.toggle()
  end, { desc = "Toggle Pomodoro status window" })

  vim.api.nvim_create_user_command("PomodoroReset", function()
    timer.stop()
    state.reset()
    notifications.info("Pomodoro reset.")
  end, { desc = "Reset Pomodoro sessions" })
end

---Setup autocmds
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("Pomodoro", { clear = true })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      timer.cleanup()
      ui.close()
    end,
    desc = "Cleanup Pomodoro timer on exit",
  })
end

---Setup plugin
---@param opts? table User configuration
function M.setup(opts)
  config.setup(opts)

  timer.set_notify_callback(function(event)
    notifications.show(event)
  end)

  setup_highlights()
  setup_commands()
  setup_autocmds()
end

---Get current state (for external use)
---@return PomodoroState
function M.get_state()
  return state.get()
end

---Get statusline component for lualine
---@return table
function M.get_statusline_component()
  return statusline.lualine_component()
end

---Check if timer is active
---@return boolean
function M.is_active()
  return state.is_active()
end

return M
