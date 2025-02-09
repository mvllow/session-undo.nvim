.PHONY: test

PLENARY_PATH := ${HOME}/.local/share/nvim/site/pack/vendor/start/plenary.nvim

test:
	@if [ ! -d "$(PLENARY_PATH)" ]; then \
		git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_PATH); \
	fi
	nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
