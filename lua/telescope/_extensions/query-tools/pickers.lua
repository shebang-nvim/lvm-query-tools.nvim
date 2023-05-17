---@tag telescope-file-browser.picker
---@config { ["module"] = "telescope-file-browser.picker" }

---@brief [[
--- You can use the file browser as follows
--- <code>
--- :lua vim.api.nvim_set_keymap(
---    "n",
---    "<space>fb",
---    "<cmd>lua require 'telescope'.extensions.file_browser.file_browser()<CR>",
---    {noremap = true}
--- )
--- </code>
---@brief ]]

local pickers = require "telescope.pickers"
local conf_tele = require("telescope.config").values
local config = require("telescope._extensions.query-tools.config")
local qt_finders = require "telescope._extensions.query-tools.finders"
local qt_utils = require "telescope._extensions.query-tools.utils"

local Path = require "plenary.path"
local os_sep = Path.path.sep

-- enclose in module for docgen
local qt_pickers = {}

local function make_title(opts)
  local s = string.format("[%s LVM.Kind:%s]", config.values.kinds[opts.kind].icon, opts.kind)
  return s
end
qt_pickers.query_picker = function(opts)
  opts = opts or {}

  local cwd = vim.loop.cwd()

  opts.cwd_to_path = vim.F.if_nil(opts.cwd_to_path, false)
  opts.cwd = opts.cwd and qt_utils.to_absolute_path(opts.cwd) or cwd
  opts.path = opts.path and qt_utils.to_absolute_path(opts.path) or opts.cwd
  opts.files = vim.F.if_nil(opts.files, true)
  opts.quiet = vim.F.if_nil(opts.quiet, false)

  opts.layout_config = vim.F.if_nil(config.values.kinds[opts.kind].layout_config, conf_tele.layout_config or {})
  opts.layout_strategy = vim.F.if_nil(config.values.layout_strategy, conf_tele.layout_strategy or "vertical")

  opts.depth = vim.F.if_nil(opts.depth, 1)
  opts.hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false)
  opts.select_buffer = vim.F.if_nil(opts.select_buffer, false)
  opts.display_stat = vim.F.if_nil(opts.display_stat, { mode = true, date = true, size = true })
  opts.custom_prompt_title = opts.prompt_title ~= nil
  opts.custom_results_title = opts.results_title ~= nil
  opts.use_fd = vim.F.if_nil(opts.use_fd, true)
  opts.git_status = vim.F.if_nil(opts.git_status, vim.fn.executable "git" == 1)
  opts.prompt_path = vim.F.if_nil(opts.prompt_path, false)

  local select_buffer = opts.select_buffer and opts.files
  -- handle case that current buffer is a hidden file
  opts.hidden = (select_buffer and vim.fn.expand("%:p:t"):sub(1, 1) == ".") and true or opts.hidden
  opts.finder = qt_finders.query_finder(opts)
  -- find index of current buffer in the results
  if select_buffer then
    local buf_name = vim.api.nvim_buf_get_name(0)
    qt_utils.selection_callback(opts, buf_name)
  end

  if opts.attach_mappings then
  else
    opts.attach_mappings = config.make_attach_mappings(opts.kind, opts)
  end
  return pickers
      .new(opts, {
        prompt_title = make_title(opts),
        results_title = Path:new(opts.path):make_relative(cwd) .. os_sep,
        prompt_prefix = qt_utils.relative_path_prefix(opts.finder),
        previewer = conf_tele.file_previewer(opts),
        sorter = conf_tele.file_sorter(opts),
        attach_mappings = opts.attach_mappings,
        -- layout_config = layout_opts.layout_config,
      })
end


qt_pickers.kinds_picker = function(opts)
  opts = opts or {}
  local cwd = vim.loop.cwd()

  opts.cwd_to_path = vim.F.if_nil(opts.cwd_to_path, false)
  opts.cwd = opts.cwd and qt_utils.to_absolute_path(opts.cwd) or cwd
  opts.path = opts.path and qt_utils.to_absolute_path(opts.path) or opts.cwd
  opts.files = vim.F.if_nil(opts.files, true)
  opts.quiet = vim.F.if_nil(opts.quiet, false)
  return pickers
      .new(opts, {
        prompt_title = "Kinds",
        previewer = conf_tele.file_previewer(opts),
        sorter = conf_tele.generic_sorter(opts),
        attach_mappings = opts.attach_mappings,
        -- layout_config = layout_opts.layout_config,
      })
end


return qt_pickers
