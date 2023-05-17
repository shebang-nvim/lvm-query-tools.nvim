local qt_utils = {}
local truncate = require("plenary.strings").truncate
local Path = require "plenary.path"
local os_sep = Path.path.sep

local Path = require "plenary.path"

qt_utils.format_for_log = function(v)
  return vim.inspect(v):gsub("\n", "")
end

-- redraws prompt and results border contingent on picker status
qt_utils.redraw_border_title = function(current_picker)
  local finder = current_picker.finder
  if current_picker.prompt_border and not finder.prompt_title then
    local new_title = finder.files and "File Browser" or "Folder Browser"
    current_picker.prompt_border:change_title(new_title)
  end
  if current_picker.results_border and not finder.results_title then
    local new_title
    if finder.files or finder.cwd_to_path then
      new_title = Path:new(finder.path):make_relative(vim.loop.cwd())
    else
      new_title = finder.cwd
    end
    local width = math.floor(a.nvim_win_get_width(current_picker.results_win) * 0.8)
    new_title = truncate(new_title ~= os_sep and new_title .. os_sep or new_title, width, nil, -1)
    current_picker.results_border:change_title(new_title)
  end
end

qt_utils.relative_path_prefix = function(finder)
  local prefix
  if finder.prompt_path then
    local path, _ = Path:new(finder.path):make_relative(finder.cwd):gsub(vim.fn.expand "~", "~")
    if path:match "^%w" then
      prefix = "./" .. path .. os_sep
    else
      prefix = path .. os_sep
    end
  end

  return prefix
end

-- trim the right most os separator from a path string
qt_utils.trim_right_os_sep = function(path)
  return path:sub(-1, -1) ~= os_sep and path or path:sub(1, -1 - #os_sep)
end

local _get_selection_index = function(path, dir, results)
  local path_dir = Path:new(path):parent():absolute()
  path = qt_utils.trim_right_os_sep(path)
  if dir == path_dir then
    for i, path_entry in ipairs(results) do
      if qt_utils.trim_right_os_sep(path_entry.value) == path then
        return i
      end
    end
  end
end

qt_utils.to_absolute_path = function(str)
  str = vim.fn.expand(str)
  return Path:new(str):absolute()
end


return qt_utils
