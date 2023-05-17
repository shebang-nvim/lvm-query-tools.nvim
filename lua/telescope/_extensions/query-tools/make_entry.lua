local entry_display        = require "telescope.pickers.entry_display"
local Path                 = require "plenary.path"

local make_entry           = {}
local set_default_entry_mt = require("telescope.make_entry").set_default_entry_mt
-- local kinds = require 'lvm.query-tools'.kinds()

make_entry.gen_from_query = function(kind)
  return function(opts)
    return function(entry)
      if entry == "" then
        return nil
      end
      local displayer = entry_display.create({
        separator = " ",
        items = {
          {
            width = 5,
          },
          {
            width = 5,
          },
          {
            width = 30,
          },
          {
            remaining = true,
          },
        },
      })

      local function make_display(entry)

        return displayer(
          {

            "icon",
            { string.format("[%s]", entry.index), "Title" },
            { string.format("[%s]", entry.index), "Title" },

            entry.name,

            { entry.filename,                     "Comment" }

          }
        )
      end


      return set_default_entry_mt({
        display = make_display,
        name = entry.name,
        filename = entry.path,
        value = entry.path,
        description = entry.description,
        ordinal = entry.name,
        Path = Path:new(entry.path)
      }, opts)
    end
  end
end


return make_entry
