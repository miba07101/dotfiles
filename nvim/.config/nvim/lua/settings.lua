local settings = {
  opt = {
    backup = false,                           -- Whether to create a backup file
    clipboard = "unnamedplus",                -- Use the system clipboard
    cmdheight = 1,                            -- Set command line height
    completeopt = { "menuone" , "noselect" }, -- Set completion options
    cursorline = true,                        -- Highlight the current line
    expandtab = true,                         -- Convert tabs to spaces
    fileencoding = "utf-8",                   -- Set the character encoding of the file where the current buffer is located
    filetype = "plugin",                      -- Allow plugin loading of file types
    fillchars = { eob = " " },                -- Disable `~` on nonexistent lines
    hidden = true,                            -- Allow switching from unsaved buffers
    hlsearch = true,                          -- Allow search highlighting
    ignorecase = true,                        -- Ignore case when searching
    incsearch = true,                         -- Highlight while searching
    iskeyword = "@,48-57,_,192-255,-",          -- Set allowed word separators (chains with _ are allowed in words)
    laststatus = 3,                           -- Enable global status bar
    list = true,                              -- Allow padding with special characters
    listchars = { eol = "¬", tab = "› " },
    matchtime = 2,                            -- Default is 5, set the duration of showmatch
    mouse = "a",                              -- Allow the use of the mouse
    number = true,                            -- Allow absolute line numbers
    numberwidth = 2,                          -- Set the width of the number column, default is 4
    pumheight = 10,                           -- Set the height of the completion menu
    scrolloff = 5,                            -- Set how many lines are always displayed on the upper and lower sides of the cursor
    sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,globals",    -- Set options for saving sessions
    shell = "/bin/bash",                      -- Set shell
    shiftwidth = 2,                           -- Number of space inserted for indentation
    showmode = false,                         -- Allows to display the current vim mode (no need)
    sidescrolloff = 8,                        -- Number of columns to keep at the sides of the cursor
    signcolumn = "yes:1",                     -- Set the width of the symbol column, if not set, it will cause an exception when displaying the icon
    smartcase = true,                         -- Intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
    smartindent = true,                       -- Set smart indent
    splitbelow = true,                        -- Splitting a new window below the current one
    splitright = true,                        -- Splitting a new window at the right of the current one
    -- syntax = "on",
    swapfile = false,                         -- Whether to create a swap file
    tabstop = 2,                              -- Number of space in a tab
    termguicolors = true,                     -- Terminal supports more colors
    timeoutlen = 300,                         -- Set timeout
    updatetime = 100,                         -- Speed up response time
    wrap = false,                             -- Disable wrapping of lines longer than the width of window
    wrapscan = true,                          -- Allows to search the entire file repeatedly (continuation of the search after the last result will return to the first result)
    writebackup = false,                      -- Whether to create backups when writing files
    guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"},  -- Cursor help: guicursor
  },
  disable_builtin_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "matchit",
    "netrw",
    "netrwFileHandlers",
    "netrwPlugin",
    "netrwSettings",
    "rrhelper",
    "spellfile_plugin",
    "tar",
    "tarPlugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  },
}

for prefix, tab in pairs(settings) do
  if prefix ~= "disable_builtin_plugins" then
    for key, value in pairs(tab) do
      vim[prefix][key] = value
    end
  else
    for _, plugin in pairs(tab) do
      vim.g["loaded_" .. plugin] = 1
    end
  end
end

return settings
