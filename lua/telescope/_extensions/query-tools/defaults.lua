local qt_actions = require "telescope._extensions.query-tools.actions"

local defaults = {
  quiet = true,
  -- Show hidden files in telescope
  show_hidden = false,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = false,

  -- What scope to change the directory, valid options are
  -- * global (default)
  -- * tab
  -- * win
  scope_chdir = "win",
  theme = 'ivy',

  mappings = {
    ["i"] = {
      ["<C-f>"] = qt_actions.find_files,
      ["<C-s>"] = qt_actions.search_in_files,
      ["<C-b>"] = qt_actions.browse_files,
      ["<C-r>"] = qt_actions.execute_query,
      ["<C-w>"] = qt_actions.change_working_directory,
    },
    ["n"] = {
      ["f"] = qt_actions.find_files,
      ["s"] = qt_actions.search_in_files,
      ["b"] = qt_actions.browse_files,
      ["e"] = qt_actions.execute_query,
      ["w"] = qt_actions.change_working_directory,
    },
  },
  kinds = {
    files = {
      icon = "",
      layout_strategy = 'vertical',
      layout_config = { height = 0.8, width = 0.8, preview_height = 0.3 },
    },
    repositories = {
      icon = "",
      layout_strategy = 'horizontal',
      layout_config = { height = 0.8, width = 0.8, preview_width = 0.4 },
    }

  }

}
return defaults
