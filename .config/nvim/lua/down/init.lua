-- nvim plugin that finds a markdown code block in the current buffer
-- and converts the buffer to that filetype and content

M = {}

function M.code_block_replace()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Find the opening fence line and extract type
  local start_line
  local filetype
  for i, line in ipairs(lines) do
    local match = line:match('^```(%w+)$')
    if match then
      start_line = i - 1 -- Convert to 0-based index
      filetype = match
      break
    end
  end

  if not start_line or not filetype then
    print("No markdown code fence found")
    return
  end

  -- Find the closing fence line
  local end_line
  for i = start_line + 1, #lines do
    if lines[i] == '```' then
      end_line = i - 1 -- Convert to 0-based index
      break
    end
  end

  if not end_line then
    print("No closing code fence found")
    return
  end

  -- Set the filetype
  vim.bo[bufnr].filetype = filetype

  -- Delete lines after the closing fence
  vim.api.nvim_buf_set_lines(bufnr, end_line, -1, false, {})

  -- Delete lines before and including the opening fence
  vim.api.nvim_buf_set_lines(bufnr, 0, start_line + 1, false, {})
end

function M.setup()
  vim.keymap.set('n', '<leader>uM', M.code_block_replace, { desc = "Convert markdown code block to buffer" })
end

return M
