local query = {}
local qt_pickers = require "telescope._extensions.query-tools.pickers"

local log = require("telescope._extensions.query-tools.log")

local Query = {}
Query.__index = Query

function Query:new(opts)
  opts = opts or {}

  log.debug("LvmQueryTools: Query:new() user opts following")

  local obj = setmetatable({
    kind = opts.kind,
    picker = qt_pickers.query_picker(opts)

  }, self)

  return obj
end

function Query:find(opts)
  self.picker:find()
end

query.Query = Query
return query
