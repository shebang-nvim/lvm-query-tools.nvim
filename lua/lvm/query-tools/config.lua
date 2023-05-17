local config = {}
---
---@alias query_kind "'repositories'"|"'files'"
---@alias store_type "'in_memory'"
---@alias store_models_config table
---@alias repository_model_opts table
---
---
---@class QueryOpts
---@field kind query_kind
---@field description string|nil

---
---@class Dictionary<T>: { [string]: T }

---@class StoreModelsConfig
---@field repositories Dictionary<repository_model_opts>
---
---@class StoreConfig`
---@field type table
---@field models Dictionary<StoreModelsConfig>
---
---@class QueryOptsDefaults
---@field kind query_kind
---@field description string|nil
---
---@class LvmQueryToolsConfig
---@field query table
---
---
---@class LvmQueryToolsConfigDefaults
---@field query QueryOptsDefaults
---@field store StoreConfig
---
---@class LvmQueryToolsConfig
---@field defaults LvmQueryToolsConfigDefaults
---@field models Dictionary<store_models_config>

local current_config

config.defaults = {
  query = {
    kind = "repositories",
    description = nil,
  },

  store = {
    type = "in_memory",
    kinds = {
      files = {
        class = "fs.file",
        icon = "",
        name = "files",
        description = "normal files",
        path = "~/dev/doc/wiki/kinds/files.md"
      },
      repositories = {
        class = "fs.directory",
        icon = "",
        description = 'git repositories',
        path = "~/dev/doc/wiki/kinds/repositories.md"
      },
      context_files = {

        class = "fs.file",
        icon = "",
        name = "files",
        description = "provides a list if files based on the current context",
        path = "~/dev/doc/wiki/kinds/context_files.md"
      },
      context = {
        class = "property",
        icon = "",
        name = "context",
        description = "provides a property list of the current context",
        path = "~/dev/doc/wiki/kinds/context.md"
      }

    },
    models = {
      files = {},
      repositories = {},
    },
  },
}

local H = {}

local _mt_config_getter = {
  __index = function(t, k)
    if k == "get" then
      return H.config
    end
    if k == "kinds" then
      return H.config.defaults.store.kinds
    end
  end,
}
local _mt_config = {
  __index = function(t, k)
    if k == "get" then
      return H.config
    elseif k == "set" then
      return function(c)
        H.config = c
        return setmetatable(H.config, _mt_config_getter)
      end
    end
  end,
}
return setmetatable(config, _mt_config)
