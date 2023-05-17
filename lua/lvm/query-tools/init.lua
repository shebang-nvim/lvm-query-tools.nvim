--- *lvm.query-tools.init* Simple model based queries
--- *LvmQueryTools*
---
--- MIT License Copyright (c) 2022 SHBorg
---
--- ==============================================================================
---
--- Query API
---
---
--- require("lvm.query-tools").query("repositories").filter(function(a)
--- 	if a[1] == "folke/dot" then
--- 		return true
--- 	end
--- end)
---

local LvmQueryTools = {}

local log = require("lvm.query-tools.log")
local store = require("lvm.query-tools.store")
local conf = require("lvm.query-tools.config")

local H = {}
H.default_config = conf.defaults
H.config = conf.get

LvmQueryTools.setup = function(config)
	-- Setup config
	config = H.setup_config(config)

	-- Apply config
	H.apply_config(config)

  -- Export module
  _G.LvmQueryTools = LvmQueryTools

	return LvmQueryTools
end

H.setup_config = function(config)
	vim.validate({ config = { config, "table", true } })
	config = vim.tbl_deep_extend("force", H.default_config, config or {})

	vim.validate({
		["config.store"] = { config.store, "table" },
	})

	vim.validate({
		["config.store.models"] = { config.store.models, "table" },
		["config.store.models.files"] = { config.store.models.files, "table", true },
		["config.store.models.repositories"] = { config.store.models.repositories, "table", true },
	})
	return config
end

H.apply_config = function(config)
	log.debug("LvmQueryTools registering state")
	store.save_data(config.store)

	config.store = nil
	local obj = { query = {} }

	obj.query.defaults = config.query
	conf.set(obj)
end

LvmQueryTools.query = store.get
LvmQueryTools.kinds = store.kinds


return LvmQueryTools
