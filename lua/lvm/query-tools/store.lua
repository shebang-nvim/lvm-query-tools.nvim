local store = {}
local state = require("lvm.query-tools.state")
local config = require("lvm.query-tools.config").get
local utils = require("lvm.query-tools.utils")

store.save_data = state.save_data
store.get = function(kind)
  if not kind or type(kind) ~= "string" then
    return {}
  end

  local kinds = state.store.models[kind]
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
