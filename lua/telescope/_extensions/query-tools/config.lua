local qt_actions = require "telescope._extensions.query-tools.actions"
local qt_utils = require "telescope._extensions.query-tools.utils"

local action_set = require "telescope.actions.set"
local actions = require("telescope.actions")
local config = {}
local defaults = require("telescope._extensions.query-tools.defaults")

local log = require("telescope._extensions.query-tools.log")
local state = require("telescope._extensions.query-tools.state")

config.valid_kinds =function ()
 return vim.tbl_keys(config.values.kinds)
end
config.make_layout_config = function(kind, opts)
  if not config.values.kinds[kind] then
    return
  end
  local kind_config = require("lvm.query-tools").kinds()

  local c = {

  }
  vim.tbl_map(function(v)
    c[v.name] = {
      layout_config = config.values.kinds[v.name].layout_config,
      layout_strategy = config.values.kinds[v.name].layout_strategy,
    }
  end, kind_config)
  return c
end

config.make_attach_mappings = function(kind, opts)
  if not config.values.kinds[kind] then
    return
  end
  return function(prompt_bufnr, map)
    for lhs, action in pairs(config.values.mappings.i) do
      map("i", lhs, action)
    end

    for lhs, action in pairs(config.values.mappings.n) do
      map("n", lhs, action)
    end
    if kind == "files" then
      actions.select_default:replace(actions.file_edit)
    elseif kind == "repositories" then
      actions.select_default:replace(qt_actions.find_files)
    end

    for index, result_value in ipairs(opts.results) do
      local total_lines = 10
      -- map("i","<A-"..tostring(index)..">", action_set.shift_selection(prompt_bufnr, 1))
      -- map("n","<A-"..tostring(index)..">", action_set.shift_selection(prompt_bufnr, 1))
      local lhs = "<A-" .. tostring(index) .. ">"
      vim.keymap.set("i", lhs, function()
        action_set.shift_selection(prompt_bufnr, index)
        actions.file_edit(prompt_bufnr)
      end, { buffer = prompt_bufnr })
    end
    -- local entry = action_state.get_selected_entry()
    -- action_set.select:replace_map {
    --   [function() return entry.Path:is_file() end] = actions.file_edit,
    --   [function() return entry.Path:is_dir() end] = actions.select_default:replace(qt_actions.find_files),
    -- }
    --      -- action_set.select:replace_if(function()
    --   -- test whether selected entry is directory
    --   local entry = action_state.get_selected_entry()
    --   return entry and entry.Path:is_dir()
    -- end, function() end },


    return true
  end
end

config.new = function(user_config, opts)
  opts = opts or { merge_global_mappings = true }
  local c = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config or {})
  if opts.merge_global_mappings then
    c.mappings = vim.tbl_deep_extend("force", c.mappings, require("telescope.config").values.mappings)
  end
  c.__index = c
  return setmetatable({}, c)
end

config.setup = function(user_config)
  log.debug(string.format("config.setup called, values=%s", qt_utils.format_for_log(user_config)))
  --- handle multiple calls to require'telescope'setup()
  --- when a config for our extension is present each call to
  --- telescope.setup results in a call to config.setup

  local skip_overwrite = true
  if config.setup_called() and not skip_overwrite then
    log.debug("setup has already been called, overwriting old values. new values following")
    log.debug(user_config)

    --- mappings must be explicitely overwritten
    local current_config = state.get_config()
    local user_mappings = user_config.mappings or {}
    user_config.mappings = nil
    local new_config = vim.tbl_deep_extend("force", state.get_config(), current_config or {})

    vim.tbl_map(function(v)
      if user_mappings[v] then
        for lhs, rhs in pairs(user_mappings[v]) do
          new_config.mappings[v][lhs] = rhs
        end
      end
    end, { "n", "i" })

    state.set_config(new_config)

    log.debug("new config after merging with current config")
    log.debug(state.get_config())
  else
    log.debug("New incoming setup call. SKIP OVERWRITING config due to feature toggle")
  end

  local c = config.new(user_config, { merge_global_mappings = true })

  state.init({
    config = c,
    key = "LvmQueryToolsTelescopeConfig"
  })
  log.debug("final config")
  log.debug(state.get_config())
end

local mt = {
  __index = function(t, k)
    if k == 'setup_called' then
      return function()
        return state.has_config()
      end
    end
    if k == 'values' then
      local c = state.get_config()
      if not c then
        c = defaults
        log.debug("config.values has no data yet, returning default values. values following")
        log.debug(c)
        return defaults
      end
      return c
    end
  end
}
return setmetatable(config, mt)
