local query = {}
local Query = {}
Query.__index = Query

Query.validate_and_merge_opts = function(opts, defaults)
	opts = vim.tbl_deep_extend("force", defaults, opts or {})
	vim.validate({
		["opts.kind"] = { opts.kind, "string" },
		["opts.description"] = { opts.description, "string", true },
	})
end

function Query:new(opts)
	opts = opts or {}

	local obj = setmetatable({
		description = opts.description,
		kind = opts.kind,
	}, self)

	return obj
end

query.Query = Query
return query
