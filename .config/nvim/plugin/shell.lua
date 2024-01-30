
--[[
Run shell command asynchronous in Neovim.

This will define new commands: X, Xr, Xw.

These new Neovim commands work like ! commands,
but allow you to continue to use Neovim in the foreground
while the command runs in the background.

Usages:
:'<, '>X command
:Xr command
:%Xw command
:Xstop
:vnoremap <leader>! :'<,'>X command<cr>


2. In the `killAsyncShell` function, the `print` statement should be replaced with `vim.api.nvim_echo` for better compatibility with Neovim.
3. In the `registerXCommands` function, the `vim.cmd` calls should be replaced with `vim.api.nvim_command` for better compatibility with Neovim.
4. The `MAX_LENGTH` constant is set to 100000, but it's not clear why this specific value was chosen. It would be helpful to add a comment explaining the reasoning behind this choice.
5. The `asyncShell` function has a nested function `on_exit` that is quite long and complex. It would be better to refactor this into a separate function for better readability and maintainability.
6. There are several commented-out lines of code and print statements in the `asyncShell` function. These should be removed or replaced with proper logging if necessary.

7. The `asyncShell` function has a lot of logic related to handling ranges and selections. It would be helpful to add more comments explaining the reasoning behind this logic and how it works.

8. The `asyncShell` function takes an `operation` parameter that can be '!', 'r', or 'w'. It would be better to use an enumeration or constants for these values to make the code more readable and less error-prone.

9. The `asyncShell` function uses the `vim.fn` namespace for some operations, such as `jobstart`, `chansend`, and `chanclose`. It would be better to use the `vim.api.nvim_*` functions for better compatibility with Neovim.

10. The code uses single quotes for some strings and double quotes for others. It would be better to use a consistent style throughout the code.

TODOS:

* Start over with TDD+AI development
* cgi-gateway: name, selection, dirty? 
* Fix bounds error on last line without newline

--]]

MARK_NS = vim.api.nvim_create_namespace('asyncShell')
MAX_LENGTH = 100000

last_job_id = 0

-- Kill the last run asynchronous command
function killAsyncShell()
  if last_job_id ~= 0 then
    vim.fn.jobstop(last_job_id)
    print(string.format("Job %d killed", last_job_id))
    last_job_id = 0
  end
end

--[[
-- Run shell command asynchronously.
--
-- command - the shell command
-- operation - !, r, or w
-- line1 - the first line of a range.  optional.
-- line2 - the last line of a range.  optional.
--]]
function asyncShell(command, operation, line1, line2)
  local bufnum = vim.api.nvim_get_current_buf()
  local start_row, start_col, end_row, end_col

  -- :r !command
  if operation == 'r' and line1 then
    start_row = line1
    start_col = 1
    end_row = line1
    end_col = 1
  else
    _, start_row, start_col = unpack(vim.fn.getpos("'<"))
    _, end_row,   end_col   = unpack(vim.fn.getpos("'>"))

    -- print(
    --   command .. ', ' .. bufnum .. ', (' .. start_row .. '/' .. line1 .. ',' .. start_col .. '), (' .. end_row .. '/' .. line2 .. ', ' .. end_col .. ')')
    if start_row ~= line1 or end_row ~= line2 then
      -- If visual-mode selection is not the same as the range, use the range
      -- print 'V mode'
      start_row = line1
      start_col = 1
      end_row = line2 + 1
      end_col = 1
    end
    if end_col >= MAX_LENGTH then
      -- print 'max len'
      local last_line_text = vim.api.nvim_buf_get_lines(bufnum, end_row - 1, end_row, false)[1]
      end_col = #last_line_text + 1
    end
  end

  -- nvim api is zero based
  start_row = start_row - 1
  start_col = start_col - 1
  end_row = end_row - 1
  end_col = end_col - 1
  -- lua print empty line.

  local selected_lines = vim.api.nvim_buf_get_text(
    bufnum, start_row, start_col, end_row, end_col, {})
  -- print(string.format("[%s]", table.concat(selected_lines, "] [")))

  -- Save as marks so they can move with edits
  -- nvim_buf_set_extmark({buffer}, {ns_id}, {line}, {col}, {*opts})
  local mark1 = vim.api.nvim_buf_set_extmark(bufnum, MARK_NS, start_row, start_col, {})
  local mark2 = vim.api.nvim_buf_set_extmark(bufnum, MARK_NS, end_row,   end_col, {})
  local output = {}
  local job_id = vim.fn.jobstart(command, {
    on_stdout = function(_, data, _)
      output = data
    end,
    on_stderr = function(_, data, _)
      if #data > 0 then
        print(table.concat(data, "\n"))
      end
    end,
    on_exit = function(exit_job_id, code, _)
      if code ~= 0 then
        print(string.format("[%s](%d) exited with code %d", command, exit_job_id, code))
      else
        if operation ~= 'w' then
          start_row, start_col = unpack(vim.api.nvim_buf_get_extmark_by_id(bufnum, MARK_NS, mark1, {}))
          end_row,   end_col   = unpack(vim.api.nvim_buf_get_extmark_by_id(bufnum, MARK_NS, mark2, {}))
          -- print("Original Changed lines " .. (end_row - start_row + 1))

          -- to avoid disrupting meantime user edits,
          -- reduce change start to the first line where the original input differs
          -- while start_row < end_row and selected_lines[1] == output[1] do
          --   table.remove(selected_lines, 1)
          --   table.remove(output, 1)
          --   start_row = start_row + 1
          --   start_col = 0
          -- end
          -- TODO: fix bugs
          -- reduce change end to the last line where the original input differs
          -- while start_row <= end_row and #output > 0 and selected_lines[#selected_lines] == output[#output] do
          --   table.remove(selected_lines, #selected_lines)
          --   table.remove(output, #output)
          --   end_row = end_row - 1
          --   if start_row <= end_row then
          --     local last_line_text = vim.api.nvim_buf_get_lines(bufnum, end_row, end_row + 1, false)[1]
          --     end_col = #last_line_text
          --   end
          -- end
          -- print("Reduced Changed lines " .. (end_row - start_row + 1))

          -- nothing left.  TODO: remove this.
          -- if start_row > end_row then
          --   end_row = start_row
          --   end_col = start_col
          -- end
          vim.api.nvim_buf_set_text(
            bufnum, start_row, start_col, end_row, end_col, output)
        end

        print(string.format("%s done", command, exit_job_id))
      end
      vim.api.nvim_buf_del_extmark(bufnum, MARK_NS, mark1)
      vim.api.nvim_buf_del_extmark(bufnum, MARK_NS, mark2)

      if last_job_id == job_id then
        last_job_id = 0
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  vim.fn.chansend(job_id, selected_lines)
  vim.fn.chanclose(job_id, "stdin")

  last_job_id = job_id
  print(string.format("Running: [%s] To kill :call jobstop(%d)", command, job_id))
end

function registerXCommands()
  -- :X is similar to :!command
  vim.cmd([[command! -nargs=1 -range X  lua asyncShell(<q-args>, '!', <line1>, <line2>) ]])
  -- :Xr is imilar to :r !command
  vim.cmd([[command! -nargs=1 -range Xr lua asyncShell(<q-args>, 'r', <line1>, <line2>) ]])
  -- :Xw is similar to :w !command
  vim.cmd([[command! -nargs=1 -range Xw lua asyncShell(<q-args>, 'w', <line1>, <line2>) ]])
  -- Xstop to kill last run command
  vim.cmd([[command! Xstop lua killAsyncShell() ]])
end

-- Register async shell commands
registerXCommands()
