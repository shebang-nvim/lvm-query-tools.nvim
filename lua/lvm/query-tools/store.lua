local store = {}
local state = require("lvm.query-tools.state")
local utils = require("lvm.query-tools.utils")

local function wrap_kind(models, kind)
  for k, _ in pairs(models or {}) do
    models[k].kind = kind
  end
  return models
end

store.save_data = state.save_data
store.get = function(kind)
  if not kind or type(kind) ~= "string" then
    return {}
  end

  local kinds = wrap_kind(state.store.models[kind],kind)

  if kind == 'kinds' then
    kinds = vim.tbl_keys(state.store.models)
  end

  if kinds then
    if kind ~= 'kinds' then
      kinds = utils.flatten_dict(kinds)
    end
    return setmetatable(kinds, {
      __index = function(t, k)
        if k == "filter" then
          return function(opts)
            local result = vim.tbl_filter(function(a)
              return opts(a)
              -- opts.predicate(a)
            end, kinds)
            return result
          end
        end
      end,
      __called = function(t, ...)
      end,
    })
  end

  return {}
end

store.kinds = function(opts)
  opts = opts or {}

  kinds = state.store.kinds

  if kinds then
    return setmetatable(kinds, {
      __index = function(t, k)
        if k == "filter" then
          return function(opts)
            local result = vim.tbl_filter(function(a)
              return opts(a)
              -- opts.predicate(a)
            end, kinds)
            return result
          end
        end
      end,
      __called = function(t, ...)
      end,
    })
  end

  return {}
end


return store
