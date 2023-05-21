local p_debug = vim.fn.getenv "DEBUG_LVM_QUERY_TOOLS"
if p_debug == vim.NIL then
  p_debug = false
end

---
--- Penlight functions
--- @see https://github.com/lunarmodules/Penlight/blob/master/lua/pl/stringx.lua
---
---
--- is the object either a function or a callable object?.
--- @param obj Object to check.
local function is_callable(obj)
  return type(obj) == 'function' or getmetatable(obj) and getmetatable(obj).__call and true
end

local gsub = string.gsub
local pack = table.pack
local unpack = unpack or table.unpack

local function _substitute(s, tbl, safe)
  local subst
  if is_callable(tbl) then
    subst = tbl
  else
    function subst(f)
      local s = tbl[f]
      if not s then
        if safe then
          return f
        else
          error("not present in table " .. f)
        end
      else
        return s
      end
    end
  end
  local res = gsub(s, '%${([%w_]+)}', subst)
  return (gsub(res, '%$([%w_]+)', subst))
end
---
--- Python-style formatting operator.
-- Calling `text.format_operator()` overloads the % operator for strings to give
-- Python/Ruby style formated output.
-- This is extended to also do template-like substitution for map-like data.
--
-- Note this goes further than the original, and will allow these cases:
--
-- 1. a single value
-- 2. a list of values
-- 3. a map of var=value pairs
-- 4. a function, as in gsub
--
-- For the second two cases, it uses $-variable substituion.
--
-- When called, this function will monkey-patch the global `string` metatable by
-- adding a `__mod` method.
--
-- See <a href="http://lua-users.org/wiki/StringInterpolation">the lua-users wiki</a>
--
-- @usage
-- require 'pl.text'.format_operator()
-- local out1 = '%s = %5.3f' % {'PI',math.pi}                   --> 'PI = 3.142'
-- local out2 = '$name = $value' % {name='dog',value='Pluto'}   --> 'dog = Pluto'
local stringx = {}
function stringx.format_operator()
  local format = string.format

  -- a more forgiving version of string.format, which applies
  -- tostring() to any value with a %s format.
  local function formatx(fmt, ...)
    local args = pack(...)
    local i = 1
    for p in fmt:gmatch('%%.') do
      if p == '%s' and type(args[i]) ~= 'string' then
        args[i] = tostring(args[i])
      end
      i = i + 1
    end
    return format(fmt, unpack(args))
  end

  local function basic_subst(s, t)
    return (s:gsub('%$([%w_]+)', t))
  end

  getmetatable("").__mod = function(a, b)
    if b == nil then
      return a
    elseif type(b) == "table" and getmetatable(b) == nil then
      if #b == 0 then -- assume a map-like table
        return _substitute(a, b, true)
      else
        return formatx(a, unpack(b))
      end
    elseif type(b) == 'function' then
      return basic_subst(a, b)
    else
      return formatx(a, b)
    end
  end
end

-- User configuration section
local log_config = {
  -- Name of the plugin. Prepended to log messages
  plugin = "LvmQueryTools.Telescope",

  -- Should print the output to neovim while running
  -- values: 'sync','async',false
  use_console = "async",

  -- Should highlighting be used in console (using echohl)
  highlights = true,

  -- Should write to a file
  use_file = true,

  -- Should write to the quickfix list
  use_quickfix = false,

  -- Any messages above this level will be logged.
  level = p_debug and "debug" or "info",

  -- Level configuration
  modes = {
    { name = "trace", hl = "Comment" },
    { name = "debug", hl = "Comment" },
    { name = "info",  hl = "None" },
    { name = "warn",  hl = "WarningMsg" },
    { name = "error", hl = "ErrorMsg" },
    { name = "fatal", hl = "ErrorMsg" },
  },

  -- Can limit the number of decimals displayed for floats
  float_precision = 0.01,
}
local _logger = require 'plenary.log'.new(log_config)
-- a more forgiving version of string.format, which applies
-- tostring() to any value with a %s format.
local function formatx(fmt, ...)
  local args = pack(...)
  local i = 1
  for p in fmt:gmatch('%%.') do
    if p == '%s' and type(args[i]) ~= 'string' then
      args[i] = tostring(args[i])
    end
    i = i + 1
  end
  return string.format(fmt, unpack(args))
end


-- local function wrap_log(f1, f2, ...)
--   f2(f1(...))
-- end
--
-- local log = {}
--
-- log.debug = function (...)
--   return wrap_log(formatx, _logger.debug, ...)
-- end
-- log.info = function (...)
--   return wrap_log(formatx, _logger.debug, ...)
-- end


-- log.debug("this string=%s", "hello")
return _logger
