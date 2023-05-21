local store = {}
local formatter = {}
local enhancer = {}

local state = require("lvm.query-tools.state")
local utils = require("lvm.query-tools.utils")


local defaults = {
  reducer = {

    keys = false,
  },
  formatter = {
    flatten = true,
  },
  query = {
    enhance = {
      with_path = true,
      with_kind = true,
    }
  }
}
formatter._reducer = {}
formatter._processors = {}
formatter._processors.flatten = function(data, opts)
  opts = opts or {}
  return utils.flatten_dict(data, opts.key_maker)
end

formatter._reducer.keys = function(data, opts)
  opts = opts or {}
  return vim.tbl_keys(data)
end


store.save_data = state.save_data

formatter.kinds = function(data, opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})


  local function normalize(models, kind)
    for k, _ in pairs(models or {}) do
        models[k].kind = kind
    end
    return models
  end

  if opts.kind then
    data = normalize(data, opts.kind)
  end
  -- disdable flatten when only keys are requested
  if opts.reducer.keys then
    opts.formatter.flatten = false
  end

  if opts.formatter.flatten then
    data = formatter._processors.flatten(data, opts)
  end

  if opts.reducer.keys then
    data = formatter._reducer.keys(data)
  end
  return data
end
enhancer._mixins = {}

enhancer._mixins.path = function(parent, path)
  local Path = require("plenary.path")
  local mt_path = {
    Path = Path:new(path),
    __index = function(t, k)
      if parent[k] then
        return parent[k]
      elseif Path[k] then
        return Path[k]
      end
    end
  }
end

enhancer.query = function(data, opts)
  -- code
  if opts.enhance.with_path then
    for index, _ in ipairs(data) do
      if type(data[index].path) == 'string' then
        setmetatable(data[index], enhancer._mixins.path(data[index], data[index].path))
      end
    end
  end
end
store.query = function(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  if not opts.kind or type(opts.kind) ~= "string" then
    return {}
  end

  -- local kinds = wrap_kind(state.store.models[kind], kind)

  local query_result = formatter.kinds(state.store.models[opts.kind], {
    kind = opts.kind,
    key_maker = function(v)
      return { "id", v }
    end
  })

  -- if kind == 'kinds' then
  --   kinds = vim.tbl_keys(state.store.models)
  -- end

  if query_result then
    -- if kind ~= 'kinds' then
    --   kinds = utils.flatten_dict(kinds)
    -- end
    return setmetatable(query_result, {
      __index = function(t, k)
        if k == "filter" then
          return function(opts)
            local result = vim.tbl_filter(function(a)
              return opts(a)
              -- opts.predicate(a)
            end, query_result)
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

  local function process(data, opts)
  end

  local kinds = formatter.kinds(state.store.kinds, opts)

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
