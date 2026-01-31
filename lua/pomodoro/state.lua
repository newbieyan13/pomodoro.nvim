---@alias PomodoroStatus "idle" | "work" | "short_break" | "long_break" | "paused"

---@class PomodoroState
---@field status PomodoroStatus
---@field time_remaining number
---@field time_total number
---@field sessions_completed number
---@field paused_at number|nil
---@field started_at number|nil
---@field paused_status PomodoroStatus|nil

local M = {}

---@type PomodoroState
local _state = {
  status = "idle",
  time_remaining = 0,
  time_total = 0,
  sessions_completed = 0,
  paused_at = nil,
  started_at = nil,
  paused_status = nil,
}

---@type fun(state: PomodoroState)[]
local _observers = {}

---Notify all observers of state change
local function notify_observers()
  local state_copy = M.get()
  for _, observer in ipairs(_observers) do
    local ok, err = pcall(observer, state_copy)
    if not ok then
      vim.schedule(function()
        vim.notify("Pomodoro observer error: " .. tostring(err), vim.log.levels.ERROR)
      end)
    end
  end
  vim.schedule(function()
    vim.cmd("redrawstatus")
  end)
end

---Get current state (returns deep copy for immutability)
---@return PomodoroState
function M.get()
  return vim.deepcopy(_state)
end

---Update state immutably
---@param changes table Partial state to merge
---@return PomodoroState New state
function M.update(changes)
  _state = vim.tbl_extend("force", {}, _state, changes)
  notify_observers()
  return M.get()
end

---Reset state to initial values
---@return PomodoroState
function M.reset()
  _state = {
    status = "idle",
    time_remaining = 0,
    time_total = 0,
    sessions_completed = 0,
    paused_at = nil,
    started_at = nil,
    paused_status = nil,
  }
  notify_observers()
  return M.get()
end

---Subscribe to state changes
---@param callback fun(state: PomodoroState)
---@return fun() Unsubscribe function
function M.subscribe(callback)
  table.insert(_observers, callback)
  return function()
    for i, observer in ipairs(_observers) do
      if observer == callback then
        table.remove(_observers, i)
        break
      end
    end
  end
end

---Check if timer is active (not idle or paused)
---@return boolean
function M.is_active()
  local status = _state.status
  return status == "work" or status == "short_break" or status == "long_break"
end

---Check if timer is in a break state
---@return boolean
function M.is_break()
  local status = _state.status
  return status == "short_break" or status == "long_break"
end

return M
