---@tag telescope-file-browser.finders
---@config { ["module"] = "telescope-file-browser.finders" }

---@brief [[
--- The file browser finders power the picker with both a file and folder browser.
---@brief ]]

local qt_make_entry = require "telescope._extensions.query-tools.make_entry"
local lvm_qt_utils = require("lvm.query-tools.utils")
local finders = require "telescope.finders"


local qt_finders = {}

local has_fd = vim.fn.executable "fd" == 1

qt_finders.kinds_finder = function(opts)
  opts = opts or {}

  local query_result = require("lvm.query-tools").kinds(opts)

  local results = {}
  for index, value in ipairs(query_result) do
    table.insert(results, {
      name = value[1].name,
      kind = "kinds",
      index = index,
      icon = value[1].icon,

      class = value[1].class,
      text = value[1].description,
      path = value[1].path,
    })
  end
  --
  --
  opts.results = results
  return finders.new_table({
    results = results,
    cwd_to_path = opts.cwd_to_path,
    cwd = opts.cwd_to_path and opts.path or opts.cwd, -- nvim cwd
    path = vim.F.if_nil(opts.path, opts.cwd),         -- current path for file browser
    add_dirs = vim.F.if_nil(opts.add_dirs, true),
    hidden = vim.F.if_nil(opts.hidden, false),
    depth = vim.F.if_nil(opts.depth, 1),               -- depth for file browser
    auto_depth = vim.F.if_nil(opts.auto_depth, false), -- depth for file browser
    respect_gitignore = vim.F.if_nil(opts.respect_gitignore, has_fd),
    files = vim.F.if_nil(opts.files, true),            -- file or folders mode
    grouped = vim.F.if_nil(opts.grouped, false),
    quiet = vim.F.if_nil(opts.quiet, false),
    select_buffer = vim.F.if_nil(opts.select_buffer, false),
    hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false),
    collapse_dirs = vim.F.if_nil(opts.collapse_dirs, false),
    git_status = vim.F.if_nil(opts.git_status, true),
    entry_maker = qt_make_entry.gen_from_query(opts.kind)(opts),
    close = function(self)
      self._finder = nil
    end,
    prompt_title = "Kinds",
    results_title = opts.custom_results_title,
    prompt_path = opts.prompt_path,
    use_fd = vim.F.if_nil(opts.use_fd, true),

  })
end
--- Returns a finder that returns files or folder from a query
---@param opts table: options to pass to the picker
---
qt_finders.query_finder = function(opts)
  opts = opts or { query_kind = "repositories" }

  local query_result = require("lvm.query-tools").query(opts.kind)

  local results = {}
  for index, value in ipairs(query_result) do
    table.insert(results, {
      name = value[1],
      kind = opts.kind,
      index = index,
      repository = lvm_qt_utils.normalize_repository(value[1]),
      text = value[2].description,
      path = vim.fn.expand(value[2].path),
    })
  end

  opts.results = results
  return finders.new_table({
    results = results,
    cwd_to_path = opts.cwd_to_path,
    cwd = opts.cwd_to_path and opts.path or opts.cwd, -- nvim cwd
    path = vim.F.if_nil(opts.path, opts.cwd),         -- current path for file browser
    add_dirs = vim.F.if_nil(opts.add_dirs, true),
    hidden = vim.F.if_nil(opts.hidden, false),
    depth = vim.F.if_nil(opts.depth, 1),               -- depth for file browser
    auto_depth = vim.F.if_nil(opts.auto_depth, false), -- depth for file browser
    respect_gitignore = vim.F.if_nil(opts.respect_gitignore, has_fd),
    files = vim.F.if_nil(opts.files, true),            -- file or folders mode
    grouped = vim.F.if_nil(opts.grouped, false),
    quiet = vim.F.if_nil(opts.quiet, false),
    select_buffer = vim.F.if_nil(opts.select_buffer, false),
    hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false),
    collapse_dirs = vim.F.if_nil(opts.collapse_dirs, false),
    git_status = vim.F.if_nil(opts.git_status, true),
    entry_maker = qt_make_entry.gen_from_query(opts.kind)(opts),
    close = function(self)
      self._finder = nil
    end,
    prompt_title = opts.custom_prompt_title,
    results_title = opts.custom_results_title,
    prompt_path = opts.prompt_path,
    use_fd = vim.F.if_nil(opts.use_fd, true),

  })
end



return qt_finders
