local M = {}

--[[
~/.config/nvim/lua/which-key/plugins/briefmarks.lua

This extends which-key/plugins/marks.lua with these changes:

* Only show subset of marks
  * Letters, upper+lower case
  * ^ . '
* Don't show duplicate marks

You must disable "marks" and enable "briefmarks" to use this.

FUTURE:
Submit a pull request.  no_dups, no_digits, globals_first, whitelist
Do a better job at comparing marks
Display tree-sitter location
Custom label for current mark
In tree view, show which global marks
In telescope marks, way to delete marks
In marks.nvim, fix dm<upper>
--]]

local marks_module = require('which-key.plugins.marks')

M.name = "briefmarks"

M.actions = marks_module.actions

function M.setup() end

M.allowed_marks = { ".", "'" }

---@type Plugin
---@return PluginItem[]
function M.run(_trigger, _mode, buf)
  local marks = marks_module.run(_trigger, _mode, buf)

  local unique_values = {}
  for i = #marks, 1, -1 do
    local key = marks[i].key
    local value = marks[i].value

    if (key:match("^%a$") or vim.tbl_contains(M.allowed_marks, key))
        and not unique_values[value] then
      -- mark is allowed, but don't let duplicates later
      unique_values[value] = true
    else
      -- Remove non-unique marks or unsupported marks
      table.remove(marks, i)
    end
  end

  return marks
end

return M
