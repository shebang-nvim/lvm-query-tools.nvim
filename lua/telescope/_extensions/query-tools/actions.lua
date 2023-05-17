---@tag query-tools.actions
---@config { ["module"] = "query-tools.actions" }

---@brief [[
--- The file browser actions are functions enable file system operations from within the file browser picker.
--- In particular, the actions include creation, deletion, renaming, and moving of files and folders.
---
--- You can remap actions as follows:
--- <code>
--- local fb_actions = require "telescope".extensions.file_browser.actions
--- require('telescope').setup {
---   extensions = {
---     file_browser = {
---       mappings = {
---         ["n"] = {
---           ["<C-a>"] = fb_actions.create,
---           ["<C-d>"] = function(prompt_bufnr)
---               -- your custom function logic here
---               ...
---             end
---         }
---       }
---     }
---   }
--- }
--- </code>
---@brief ]]

-- local a = vim.api
--
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require("lvm.query-tools.utils")
local transform_mod = require("telescope.actions.mt").transform_mod
--
local builtin = require("telescope.builtin")

local log = require("telescope._extensions.query-tools.log")
local Path = require "plenary.path"
local qt_actions = setmetatable({
  picker = {
    files = false,
    repositories = false,
  },
}, {
  __index = function(_, k)
    error("Key does not exist for 'qt_actions': " .. tostring(k))
  end,
})

local config = {
  options = {
    scope_chdir = "win",
    silent_chdir = true,
  }
}

local function set_pwd(dir_picked, method)
  if dir_picked == nil then
    return false
  end
  local file = Path:new(dir_picked)
  local dir = Path:new(dir_picked)

  if file:is_file() then
    dir = Path:new(utils.get_root(tostring(file)))
  end

  file = nil

  if vim.fn.getcwd() == tostring(dir) then
    return false
  end

  local scope_chdir
  ---FIXME: config.options is nil?
  if not config or not config.options then
    scope_chdir = "win"
  else
    scope_chdir = config.options.scope_chdir
  end
  if scope_chdir == "global" then
    vim.api.nvim_set_current_dir(tostring(dir))
  elseif scope_chdir == "tab" then
    vim.cmd("tcd " .. tostring(dir))
  elseif scope_chdir == "win" then
    vim.cmd("lcd " .. tostring(dir))
  else
    return false
  end

  if config.silent_chdir == false then
    vim.notify("Set CWD to " .. tostring(dir) .. " using " .. method)
  end
  return true
end

qt_actions.with_change_working_directory = function(chdir, f)
  return function(prompt_bufnr, prompt)
    local project_path, chdir_wanted = chdir(prompt_bufnr, true)
    if chdir_wanted then
      f(prompt_bufnr, { cwd = project_path })
    end
  end
end

qt_actions.change_working_directory = function(prompt_bufnr, prompt)
  local selected_entry = action_state.get_selected_entry()
  if selected_entry == nil then
    actions.close(prompt_bufnr)
    return
  end
  local project_path = selected_entry.value
  if prompt == true then
    actions.close(prompt_bufnr)
  else
    actions.close(prompt_bufnr)
  end
  local chdir_wanted = set_pwd(project_path, "telescope")

  log.debug(string.format("LvmQueryTools: change_working_directory chdir_wanted=%s", chdir_wanted))
  log.debug(string.format("LvmQueryTools: change_working_directory project_path=%s", project_path))
  return project_path, chdir_wanted
end

local find_files = function(prompt_bufnr, opts)
  local opt = {
    cwd = opts.cwd,
    hidden = config.options.show_hidden,
    mode = "insert",
  }
  builtin.find_files(opt)
end

local browse_files = function(prompt_bufnr, opts)
  local opt = {
    cwd = opts.cwd,
    hidden = config.options.show_hidden,
  }
  builtin.file_browser(opt)
end

local search_in_files = function(prompt_bufnr, opts)
  local opt = {
    cwd = opts.cwd,
    hidden = config.options.show_hidden,
    mode = "insert",
  }
  builtin.live_grep(opt)
end


qt_actions.find_files = qt_actions.with_change_working_directory(qt_actions.change_working_directory, find_files)
qt_actions.browse_files = qt_actions.with_change_working_directory(qt_actions.change_working_directory, browse_files)
qt_actions.search_in_files = qt_actions.with_change_working_directory(qt_actions.change_working_directory, search_in_files)

--- Toggle between file and folder browser for |telescope-file-browser.picker.file_browser|.
---@param prompt_bufnr number: The prompt bufnr
-- qt_actions.toggle_browser = function(prompt_bufnr, opts)
--   opts = opts or {}
--   opts.reset_prompt = vim.F.if_nil(opts.reset_prompt, true)
--   local current_picker = action_state.get_current_picker(prompt_bufnr)
--   local finder = current_picker.finder
--   finder.files = not finder.files
--
--   fb_utils.redraw_border_title(current_picker)
--   current_picker:refresh(finder, { reset_prompt = opts.reset_prompt, multi = current_picker._multi })
-- end
--

qt_actions.execute_query = function(prompt_bufnr)
  local _, chdir_wanted = qt_actions.change_working_directory(prompt_bufnr, true)
  local opt = {
    cwd_only = true,
    -- hidden = config.options.show_hidden,
  }
  if chdir_wanted then
    builtin.oldfiles(opt)
  end
end
--
qt_actions.picker.repositories = false

qt_actions = transform_mod(qt_actions)
return qt_actions
