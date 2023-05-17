--- Mostly taken from telescope-file-browser.nvim
---
--- TODO
---
---   * thin out and delegate file browsing to telescope-file-browser.nvim
---   * provide pickers for a query menu which lists all kinds
---
---
local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return
end

local log = require("telescope._extensions.query-tools.log")
local api = require("telescope._extensions.query-tools.api")


local function checkhealth()
  vim.health.report_ok "TODO: health not implemented"
  -- local has_sql, _ = pcall(require, "sqlite")
  -- if has_sql then
  --   vim.health.report_ok "sql.nvim installed."
  --   -- return "MOOP"
  -- else
  --   vim.health.report_error "Need sql.nvim to be installed."
  -- end
end


return telescope.register_extension {
  setup = function(ext_config, config)
    ext_config = ext_config or {}

    require 'telescope._extensions.query-tools.config'.setup(ext_config)
  end,
  exports = {
    -- query = function(opts)
    --   -- builtin.query.repositories:find(opts)
    --   return builtin.query(opts)
    -- end,
    files = function()
      return api.query().files():find()
    end,
    repositories = function()
      return api.query().repositories():find()
    end,

  },
  health = checkhealth,
}
