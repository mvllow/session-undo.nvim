local M = {}

function M.setup()
	if not vim.o.undofile then
		vim.notify("Please enable persistent undo: `vim.o.undofile = true`", vim.log.levels.WARN)
	end

	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local undotree = vim.fn.undotree()
			-- Store the current sequence number as a session boundary
			if undotree.entries and #undotree.entries > 0 then
				-- Store the boundary as a buffer variable
				vim.b[bufnr] = vim.b[bufnr] or {}
				vim.b[bufnr].session_boundary = undotree.seq_cur
			end
		end
	})

	local function is_previous_session_undo()
		local bufnr = vim.api.nvim_get_current_buf()
		local boundary = vim.b[bufnr] and vim.b[bufnr].session_boundary

		local undotree = vim.fn.undotree()
		if not undotree.entries or #undotree.entries == 0 then
			return false
		end

		local next_seq = undotree.seq_cur - 1
		return boundary and next_seq < boundary
	end

	local function safe_undo()
		if is_previous_session_undo() then
			local choice = vim.fn.confirm(
				"Warning: You're about to undo changes from a previous session. Continue?",
				"&Yes\n&No",
				2
			)
			if choice == 1 then
				vim.cmd("normal! u")
			end
			return
		end

		vim.cmd("normal! u")
	end

	vim.keymap.set("n", "u", safe_undo, { noremap = true, silent = true })
end

return M
