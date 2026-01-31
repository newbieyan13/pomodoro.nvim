# 🍅 pomodoro.nvim

A minimal and elegant Pomodoro timer for Neovim with statusline integration and floating widget.

## 📸 Screenshots
![Pomodoro](./pomodoro.png)

## ✨ Features

- ⏱️ **Complete Pomodoro workflow** - Automatic transitions between work sessions, short breaks, and long breaks
- 🎯 **Custom session durations** - Start sessions with any duration (e.g., `:PomodoroStart 45` for 45 minutes)
- 📊 **Session tracking** - Track completed Pomodoros and total productivity hours
- 🎨 **Ultra-minimal floating widget** - Non-intrusive, compact widget in the bottom-right corner
- 📍 **Statusline integration** - Real-time status with progress bar in your statusline (lualine supported)
- 📈 **Visual progress indicators** - Progress bars in both widget and statusline
- 🔔 **Customizable notifications** - Get notified when sessions start and end
- ⏸️ **Pause & Resume** - Pause your timer when interrupted
- 🎨 **Fully customizable** - Configure durations, icons, labels, colors, and messages
- 🚀 **Zero dependencies** (except nui.nvim for UI)

## 📦 Requirements

- Neovim >= 0.10.0
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) - UI component library

## 📥 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "mvtt25/pomodoro.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = {
    "PomodoroStart",
    "PomodoroStop",
    "PomodoroPause",
    "PomodoroResume",
    "PomodoroToggle",
    "PomodoroReset",
  },
  opts = {
    -- Your configuration here (see Configuration section)
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "mvtt25/pomodoro.nvim",
  requires = { "MunifTanjim/nui.nvim" },
  config = function()
    require("pomodoro").setup({
      -- Your configuration here
    })
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'MunifTanjim/nui.nvim'
Plug 'mvtt25/pomodoro.nvim'
```

Then in your `init.lua`:
```lua
require("pomodoro").setup()
```

## ⚙️ Configuration

Here's the full default configuration with explanations:

```lua
require("pomodoro").setup({
  -- Session durations in seconds
  durations = {
    work = 25 * 60,        -- 25 minutes for work sessions
    short_break = 5 * 60,  -- 5 minutes for short breaks
    long_break = 15 * 60,  -- 15 minutes for long breaks
  },

  -- Number of work sessions before a long break
  sessions_until_long_break = 4,

  -- Notification settings
  notifications = {
    enabled = true,  -- Enable/disable all notifications
    work_start = "Let's focus! Work session started.",
    work_end = "Great work! Time for a break.",
    break_start = "Break started. Relax!",
    break_end = "Break over. Ready to work?",
  },

  -- Floating widget appearance (used by :PomodoroToggle)
  ui = {
    border_style = "rounded",  -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    width = 50,                -- Not used in minimal widget
    height = 15,               -- Not used in minimal widget
  },

  -- Statusline component configuration
  statusline = {
    enabled = true,           -- Show in statusline
    icon_work = "🍅",         -- Icon for work sessions
    icon_break = "☕",        -- Icon for breaks
    icon_paused = "⏸",       -- Icon when paused
    icon_idle = "",           -- Icon when idle (empty = hidden)
    label_work = "WORK",      -- Label for work sessions
    label_break = "BREAK",    -- Label for breaks
    label_paused = "PAUSED",  -- Label when paused
    format = "%s %s %02d:%02d",  -- Format: label, icon, minutes, seconds
  },

  -- Highlight colors for different states
  highlights = {
    work = { fg = "#f38ba8", bold = true },    -- Red for work (Catppuccin Mocha)
    ["break"] = { fg = "#a6e3a1", bold = true }, -- Green for breaks
    idle = { fg = "#7f849c" },                  -- Gray for idle
  },
})
```

## 🎯 Usage

### Commands

| Command | Description |
|---------|-------------|
| `:PomodoroStart [duration]` | Start a work session (optional: duration in minutes) |
| `:PomodoroStop` | Stop the current session |
| `:PomodoroPause` | Pause the current session |
| `:PomodoroResume` | Resume from pause |
| `:PomodoroToggle` | Toggle the minimal status widget |
| `:PomodoroReset` | Reset all sessions and stop timer |

### Examples

```vim
" Start standard 25-minute session
:PomodoroStart

" Start custom 45-minute session
:PomodoroStart 45

" Start a 90-minute deep work session
:PomodoroStart 90

" Toggle the floating widget on/off
:PomodoroToggle

" Pause when interrupted
:PomodoroPause

" Resume when ready
:PomodoroResume
```

## 🔌 Statusline Integration

### Lualine

Add the Pomodoro component to your lualine configuration:

```lua
require("lualine").setup({
  sections = {
    lualine_x = {
      require("pomodoro.statusline").lualine_component(),
      "encoding",
      "fileformat",
      "filetype",
    },
  },
})
```

The statusline will display:
- `WORK 🍅 ████████░░ 24:35` - Work session (red)
- `BREAK ☕ ████░░░░░░ 04:35` - Break (green)
- `PAUSED ⏸ ████████░░ 24:35` - Paused (gray)

### Custom Statusline

If you're using a custom statusline:

```lua
local pomodoro = require("pomodoro.statusline")

-- Get the component string
local status = pomodoro.component()

-- Use it in your statusline
vim.o.statusline = "%f %m %= " .. status .. " %l:%c"
```

## 🎨 Floating Widget

Use `:PomodoroToggle` to show/hide a minimal floating widget in the bottom-right corner:

```
┌─ 🍅 ─┐
│🍅 WORK│
│ 24:35 │
│████░░░░░░ 40%│
│            │
│3 🍅 | 1.2h│
└──────────┘
```

The widget shows:
- Current status (WORK/BREAK/PAUSED) with icon
- Time remaining in MM:SS
- Progress bar with percentage
- Sessions completed and total hours

**Features:**
- Non-focusable (won't steal focus)
- Auto-updates every second
- Toggle on/off with `:PomodoroToggle`
- Compact and unobtrusive

## ⌨️ Keybindings

Here are some suggested keybindings:

```lua
vim.keymap.set("n", "<leader>ps", "<cmd>PomodoroStart<cr>", { desc = "Pomodoro: Start" })
vim.keymap.set("n", "<leader>pS", "<cmd>PomodoroStop<cr>", { desc = "Pomodoro: Stop" })
vim.keymap.set("n", "<leader>pp", "<cmd>PomodoroPause<cr>", { desc = "Pomodoro: Pause" })
vim.keymap.set("n", "<leader>pr", "<cmd>PomodoroResume<cr>", { desc = "Pomodoro: Resume" })
vim.keymap.set("n", "<leader>pt", "<cmd>PomodoroToggle<cr>", { desc = "Pomodoro: Toggle Widget" })

-- Quick start with custom durations
vim.keymap.set("n", "<leader>p3", "<cmd>PomodoroStart 30<cr>", { desc = "Pomodoro: 30 min" })
vim.keymap.set("n", "<leader>p4", "<cmd>PomodoroStart 45<cr>", { desc = "Pomodoro: 45 min" })
vim.keymap.set("n", "<leader>p6", "<cmd>PomodoroStart 60<cr>", { desc = "Pomodoro: 60 min" })
```

## 🎨 Customization Examples

### Deep Work Setup (Longer Sessions)

```lua
{
  "mvtt25/pomodoro.nvim",
  opts = {
    durations = {
      work = 50 * 60,        -- 50 minutes work
      short_break = 10 * 60, -- 10 minutes break
      long_break = 30 * 60,  -- 30 minutes long break
    },
    sessions_until_long_break = 3,
  },
}
```

### Minimal Setup (No Emojis)

```lua
{
  "mvtt25/pomodoro.nvim",
  opts = {
    statusline = {
      icon_work = "◉",
      icon_break = "◯",
      icon_paused = "⏸",
      label_work = "FOCUS",
      label_break = "REST",
      label_paused = "PAUSE",
    },
  },
}
```

### Silent Mode (No Notifications)

```lua
{
  "mvtt25/pomodoro.nvim",
  opts = {
    notifications = {
      enabled = false,
    },
  },
}
```

### Custom Theme (Tokyonight)

```lua
{
  "mvtt25/pomodoro.nvim",
  opts = {
    highlights = {
      work = { fg = "#f7768e", bold = true },    -- Red
      ["break"] = { fg = "#9ece6a", bold = true }, -- Green
      idle = { fg = "#565f89" },                  -- Gray
    },
  },
}
```

## 🔥 The Pomodoro Technique

The Pomodoro Technique is a time management method that uses timed intervals to maximize focus and productivity:

1. **Work for 25 minutes** (1 Pomodoro) 🍅
2. **Take a 5-minute break** ☕
3. **Repeat**
4. **After 4 Pomodoros, take a longer 15-minute break** 🌴

This plugin automates the entire workflow:
- Automatically transitions from work to breaks
- Tracks your completed Pomodoros
- Calculates total productivity time
- Reminds you when it's time to switch

## 🛠️ Lua API

You can also control the timer programmatically:

```lua
local timer = require("pomodoro.timer")
local ui = require("pomodoro.ui")

-- Start a session
timer.start("work")              -- Standard work session
timer.start("work", 45 * 60)     -- Custom 45-minute session

-- Control playback
timer.pause()
timer.resume()
timer.stop()

-- Show/hide widget
ui.show()
ui.close()
ui.toggle()

-- Get current state
local state = require("pomodoro.state").get()
print(state.status)              -- "work", "short_break", "long_break", "paused", "idle"
print(state.time_remaining)      -- Seconds remaining
print(state.sessions_completed)  -- Number of completed Pomodoros
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Credits

Inspired by the Pomodoro Technique® by Francesco Cirillo.

---
```lua
     ███▄ ▄███▓ ██▒   █▓▄▄▄█████▓▄▄▄█████▓
    ▓██▒▀█▀ ██▒▓██░   █▒▓  ██▒ ▓▒▓  ██▒ ▓▒
    ▓██    ▓██░ ▓██  █▒░▒ ▓██░ ▒░▒ ▓██░ ▒░
    ▒██    ▒██   ▒██ █░░░ ▓██▓ ░ ░ ▓██▓ ░ 
    ▒██▒   ░██▒   ▒▀█░    ▒██▒ ░   ▒██▒ ░ 
    ░ ▒░   ░  ░   ░ ▐░    ▒ ░░     ▒ ░░   
    ░  ░      ░   ░ ░░      ░        ░    
    ░      ░        ░░    ░        ░      
         ░         ░                    
                  ░                     
```

