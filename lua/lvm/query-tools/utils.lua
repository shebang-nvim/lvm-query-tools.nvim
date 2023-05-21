local utils = {}

utils.root_patterns = { ".git", "lua" }
---@class List<T>: { [integer]: T }
---
--- Creates a list from a dictionary. {k=v} => {{k,k}}
---@param t Dictionary<any>
---@return List<T>
utils.flatten_dict1 = function(t)
  if type(t) ~= "table" then
    return {}
  end
  local list = {}
  for k, v in pairs(t) do
    table.insert(list, 1, { k, v })
  end
  return list
end


---@class List<T>: { [integer]: T }
---
--- Creates a list from a dictionary. {k=v} => {{k,k}}
---@param t Dictionary<any>
---@return List<T>
utils.flatten_dict = function(t, key_maker, entry_maker)
  if type(t) ~= "table" then
    return {}
  end
  local list = {}

  local _key_maker = function (key)
    return {"kind", key}
  end

  local _entry_maker = function(k, v)
    v[k[1]] = k[2]
    return v
  end

  if type(entry_maker) == "function" then
    _entry_maker = entry_maker
  end

  if type(key_maker) == "function" then
    _key_maker = key_maker
  end

  for k, v in pairs(t) do
    table.insert(list, _entry_maker(_key_maker(k), v))
  end
  return list
end

utils.normalize_repository = function(s)
  if type(s) ~= "string" or s == "" then
    return
  end
  return "https://github.com/" .. s
end


---Creates a new dict of all available kinds which can be used to attach
---your own object to it
---
---result
---
---local kinds_table = {
---  files = {
---     kind = file,
---     ...
---  },
---  ... other kinds
---}
---@param opts table: merged into the returned obj
utils.new_kinds_table = function(opts)
  local all_kinds = require 'lvm.query-tools'.query("kinds")
  local obj = {
    kinds = {
    }
  }
  for _, kind in ipairs(all_kinds) do
    obj.kinds[kind] = { kind = kind }
  end

  obj = vim.tbl_deep_extend("force", obj, opts or {})
  return obj
end


-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function utils.get_root(p)
  ---@type string?
  local path = p or vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(utils.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

return utils
