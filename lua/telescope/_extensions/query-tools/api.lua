local api = {}
local query = {}

local log = require("telescope._extensions.query-tools.log")
local config = require("telescope._extensions.query-tools.config")
local Query = require("telescope._extensions.query-tools.query").Query
local Kinds = require("telescope._extensions.query-tools.kinds").Kinds
local lvm_qt_utils = require("lvm.query-tools.utils")

---
--- api.query
---
--- set defaults for a query:
---
--- ```lua
--- require 'telescope.extensions'['query_tools'].query({
---
---   kind = 'files',
---   defaults = {
---     show_hidden_files = true,
---   }
--- })
--- ```
---
---
--- query a model, for example files:
---
--- ```lua
--- require 'telescope.extensions'['query_tools'].query().files({
---
---     show_hidden_files = true,
--- })
--- ```
--- attach a filter to a query
---
--- ```lua
--- require 'telescope.extensions'['query_tools'].query().files({
---
---     show_hidden_files = true,
--- }).filter(function(v)
---
---   return true -- include obj
--- end)
--- ```
---
---USER wants to overwrite all titles for future file queries:
---require 'telescope._extensions.query-tools.query'.query(
---   {
---     kinds = {
---       files = {
---         title = 'overwrite'}
---       }
---   }
--- )
---
--- RESULT:
---[plenary] [INFO  12:03:52] ...s.nvim/lua/telescope/_extensions/query-tools/query.lua:45: {
---[plenary]   kinds = {
---[plenary]     files = {
---[plenary]       kind = "files",
---[plenary]       title = "overwrite"
---[plenary]     },
---[plenary]     repositories = {
---[plenary]       kind = "repositories"
---[plenary]     }
---[plenary]   }
---[plenary] }
---

local core_api_build_cache = {
  _property = { names = {} },
  _methods = {

  },
}
local function make_property(k, v)
  local obj = {
    __tosting = function()
      return v
    end
  }
  obj.name = k
  obj._value = v

  obj.tostring = function() return obj._value end
  table.insert(core_api_build_cache._property.names, k)
  return setmetatable(obj, {
    __index = function(t, k)
      log.info(string.format("make_property.metatable.__index: k=%s", k))
    end,
    __tosting = function()
      return obj._value
    end
  })
end

local query_api_builder = function(opts)
  if not core_api_build_cache._methods.query then
    -- _query_pickers_map = init_query_picker_table(opts)
    -- local all_kinds = require 'lvm.query-tools'.kinds({ reducer = { keys = true } })
    local all_kinds = config.valid_kinds()
    local _query_pickers_map = {}
    for _, kind in ipairs(all_kinds) do
      _query_pickers_map[kind] = function(user_opts)
        return Query:new(vim.tbl_deep_extend("force", { kind = kind }, user_opts or {}))
      end
    end

    core_api_build_cache._methods.query = _query_pickers_map
  end


  return core_api_build_cache._methods.query
end

local kinds_api_builder = function()
  if not core_api_build_cache._methods.kinds then
    local _kinds_pickers_map = {}
    -- local all_kinds = require 'lvm.query-tools'.kinds({ formatter = { flatten = true } })
    local all_kinds = config.valid_kinds()
    for _, kind in ipairs(all_kinds) do
      _kinds_pickers_map[kind] = function(user_opts)
      end
    end

    local obj = Kinds:new(vim.tbl_deep_extend("force", {}, user_opts or {}))
    core_api_build_cache._methods.kinds = _kinds_pickers_map
  end


  return core_api_build_cache._methods.kinds
end

local core_api_properties = {
  make_property('version', '0.1.0')
}
local core_api_builders = {
  query = query_api_builder,
  kinds = kinds_api_builder,
}


--- api.query must be callable
local function make_mt_api_method(method, root, cache)
  local obj = {
    -- __index = function(t, k)
    --   log.info("_mt_api_method_accessor", t, k)
    -- end,
    __call = function(t, v)
      log.info("_mt_api_method_callable", t, v)
      return cache[method]
    end
  }
  return obj
end
--- api accessor
local _mt_api_accessor = {
  __index = function(t, k)
    if vim.tbl_contains(vim.tbl_keys(core_api_builders), k) then
      log.info("_mt_api_accessor valid core api name", k)
      --- api has already been build
      --- delegate to the next chain
      if core_api_build_cache[k] then
        return core_api_build_cache[k]
      end

      local builder = core_api_builders[k]
      core_api_build_cache[k] = builder()
      return setmetatable(core_api_build_cache[k], make_mt_api_method(k, t, core_api_build_cache))
    elseif vim.tbl_contains(core_api_build_cache._property.names, k) then
      log.info("_mt_api_accessor valid core api property", k)
    end

    --- fallback always return the accessor!
    return t
  end,
}
setmetatable(api, _mt_api_accessor)


return api
