local kinds = {}
local qt_pickers = require "telescope._extensions.query-tools.pickers"


local log = require("telescope._extensions.query-tools.log")

local Kinds = {}
Kinds.__index = Kinds

function Kinds:new(opts)
  opts = opts or {}

  log.debug("LvmQueryTools: Kinds:new() user opts following")

  local obj = setmetatable({
    kind = "kinds",
    picker = qt_pickers.kinds_picker(opts)

  }, self)

  return obj
end

function Kinds:find(opts)
  self.picker:find()
end

kinds.Kinds = Kinds
return kinds
