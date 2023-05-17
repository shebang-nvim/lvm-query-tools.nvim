---*LvmTelescope.State*
---
local state_tele = require("telescope.state")
local state = {}

--- Set the status for a particular prompt bufnr
function state.set_status(prompt_bufnr, status)
  state_tele.set_status(prompt_bufnr, status)
end

function state.set_global_key(key, value)
  state_tele.set_global_key(key, value)
end

function state.get_global_key(key)
  return state_tele.get_global_key(key)
end

function state.get_status(prompt_bufnr)
  return state_tele.get_status(prompt_bufnr)
end

function state.clear_status(prompt_bufnr)
  state_tele.clear_status(prompt_bufnr)
end

function state.get_existing_prompts()
  return state_tele.get_existing_prompts()
end

local _config_key = 'LvmQueryToolsTelescopeConfig'

function state.set_config(config)
  state.set_global_key(_config_key, config)
end

function state.get_config()
  return state.get_global_key(_config_key)
end
function state.has_config()
  return state.get_global_key(_config_key) ~= nil
end


function state.init(opts)
  opts = opts or {}
  if not opts.config then
    return
  end

  state.set_config(opts.config)
end

return state
