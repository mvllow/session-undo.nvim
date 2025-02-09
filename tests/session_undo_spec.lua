local assert = require("luassert")

describe("session-undo", function()
	local session_undo

	before_each(function()
		vim.cmd("bufdo! bwipeout!")
		vim.o.undofile = true
		session_undo = require("session-undo")
		session_undo.setup()
	end)

	after_each(function()
		vim.cmd("bufdo! bwipeout!")
	end)

	local function wait_for_boundary()
		vim.cmd("sleep 100m")
	end

	it("should set session boundary when opening a file", function()
		local test_file = vim.fn.tempname()
		local f = io.open(test_file, "w")
		f:write("initial content")
		f:close()

		vim.cmd("edit " .. test_file)
		wait_for_boundary()

		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "new content" })
		vim.cmd("write")

		local bufnr = vim.api.nvim_get_current_buf()

		assert.is_not_nil(vim.b[bufnr].session_boundary)
		assert.equals(1, vim.b[bufnr].session_boundary)
	end)

	it("should warn when undoing changes from previous session", function()
		local test_file = vim.fn.tempname()
		local f = io.open(test_file, "w")
		f:write("initial content")
		f:close()

		local undodir = vim.fn.tempname()
		vim.fn.mkdir(undodir)
		local original_undodir = vim.o.undodir
		vim.o.undodir = undodir

		-- First session
		vim.cmd("edit " .. test_file)
		wait_for_boundary()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "session 1 change" })
		vim.cmd("write")
		local boundary = vim.fn.undotree().seq_cur
		vim.cmd("bwipeout!")

		vim.fn.delete(vim.fn.undofile(test_file))

		-- Second session
		vim.cmd("edit " .. test_file)
		wait_for_boundary()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "session 2 change" })
		vim.cmd("write")

		local bufnr = vim.api.nvim_get_current_buf()
		vim.b[bufnr].session_boundary = boundary

		local confirm_called = false
		local original_confirm = vim.fn.confirm
		vim.fn.confirm = function()
			confirm_called = true
			return 2
		end

		vim.cmd("normal u")

		vim.fn.confirm = original_confirm
		vim.o.undodir = original_undodir

		assert.is_true(confirm_called)
	end)

	it("should allow normal undo within same session", function()
		local test_file = vim.fn.tempname()
		local f = io.open(test_file, "w")
		f:write("initial content")
		f:close()

		vim.cmd("edit " .. test_file)
		wait_for_boundary()

		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first change" })
		vim.cmd("write")

		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "second change" })
		vim.cmd("write")

		local confirm_called = false
		local original_confirm = vim.fn.confirm
		vim.fn.confirm = function()
			confirm_called = true
			return 2
		end

		vim.cmd("normal u")
		vim.fn.confirm = original_confirm

		assert.is_false(confirm_called)
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert.equals("first change", lines[1])
	end)
end)
