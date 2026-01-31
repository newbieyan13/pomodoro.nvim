local state = require("pomodoro.state")
local config = require("pomodoro.config")

local M = {}

---@type uv.uv_timer_t?
local timer_handle = nil

---@type fun(event: string)|nil
local notify_callback = nil

---Set notification callback
---@param callback fun(event: string)
function M.set_notify_callback(callback)
  notify_callback = callback
end

---Notify event
---@param event string
local function notify(event)
  if notify_callback then
    local ok, err = pcall(notify_callback, event)
    if not ok then
      vim.schedule(function()
        vim.notify("Pomodoro notify error: " .. tostring(err), vim.log.levels.ERROR)
      end)
    end
  end
end

---Get duration for session type
---@param session_type PomodoroStatus
---@return number
local function get_duration(session_type)
  local cfg = config.get()
  if session_type == "work" then
    return cfg.durations.work
  elseif session_type == "short_break" then
    return cfg.durations.short_break
  elseif session_type == "long_break" then
    return cfg.durations.long_break
  end
  return 0
end

---Handle timer completion and state transitions
local function on_complete()
  local current = state.get()

  if current.status == "work" then
    local sessions = current.sessions_completed + 1
    local cfg = config.get()

    state.update({ sessions_completed = sessions })
    notify("work_end")

    if sessions % cfg.sessions_until_long_break == 0 then
      M.start("long_break")
    else
      M.start("short_break")
    end
  elseif current.status == "short_break" or current.status == "long_break" then
    notify("break_end")
    M.stop()
  end
end

---Timer tick - called every second
local function tick()
  local ok, err = pcall(function()
    local current = state.get()

    if current.time_remaining <= 1 then
      on_complete()
      return
    end

    state.update({ time_remaining = current.time_remaining - 1 })
  end)

  if not ok then
    vim.schedule(function()
      vim.notify("Pomodoro timer error: " .. tostring(err), vim.log.levels.ERROR)
    end)
    M.stop()
  end
end

---Start timer for given session type
---@param session_type PomodoroStatus
---@param custom_duration? number Optional custom duration in seconds
function M.start(session_type, custom_duration)
  if timer_handle then
    M.stop()
  end

  local duration = custom_duration or get_duration(session_type)
  if duration == 0 then
    vim.notify("Invalid session type: " .. tostring(session_type), vim.log.levels.ERROR)
    return
  end

  state.update({
    status = session_type,
    time_remaining = duration,
    time_total = duration,
    started_at = os.time(),
    paused_at = nil,
    paused_status = nil,
  })

  if session_type == "work" then
    notify("work_start")
  else
    notify("break_start")
  end

  timer_handle = vim.uv.new_timer()
  if timer_handle then
    timer_handle:start(
      1000,
      1000,
      vim.schedule_wrap(function()
        tick()
      end)
    )
  end
end

---Stop timer completely
function M.stop()
  if timer_handle then
    timer_handle:stop()
    timer_handle:close()
    timer_handle = nil
  end

  state.update({
    status = "idle",
    time_remaining = 0,
    time_total = 0,
    started_at = nil,
    paused_at = nil,
    paused_status = nil,
  })
end

---Pause timer
function M.pause()
  local current = state.get()

  if not state.is_active() then
    return
  end

  if timer_handle then
    timer_handle:stop()
  end

  state.update({
    status = "paused",
    paused_at = os.time(),
    paused_status = current.status,
  })
end

---Resume timer from pause
function M.resume()
  local current = state.get()

  if current.status ~= "paused" or not current.paused_status then
    return
  end

  state.update({
    status = current.paused_status,
    paused_at = nil,
    paused_status = nil,
  })

  if timer_handle then
    timer_handle:start(
      1000,
      1000,
      vim.schedule_wrap(function()
        tick()
      end)
    )
  end
end

---Toggle pause/resume
function M.toggle()
  local current = state.get()

  if current.status == "paused" then
    M.resume()
  elseif state.is_active() then
    M.pause()
  elseif current.status == "idle" then
    M.start("work")
  end
end

---Cleanup timer handle (for VimLeavePre)
function M.cleanup()
  if timer_handle then
    timer_handle:stop()
    timer_handle:close()
    timer_handle = nil
  end
end

return M
