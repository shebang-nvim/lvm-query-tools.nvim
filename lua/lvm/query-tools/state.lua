local state = {}

--- creates a new store store_accessor
--- currently this implements  the default table behaviour
---@param t0 table
---@return table
local function store_accessor(t0)
	local proxy = t0
	local mt = { -- create metatable
		__index = function(t, k)
			return t[k]
		end,
		__newindex = function(t, k, v)
			-- error("attempt to update a read-only table", 2)
			t[k] = v
		end,
	}
	setmetatable(proxy, mt)
	return proxy
end

LvmQueryToolsStore = store_accessor(_G.LvmQueryToolsStore or {kinds = {}, models = {} })

local function save_data(data)
	LvmQueryToolsStore.models = data.models
	LvmQueryToolsStore.kinds = data.kinds
end

state.save_data = save_data
state.store = LvmQueryToolsStore

return state
