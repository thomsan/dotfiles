.PHONY: bootstrap test status help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Run full bootstrap (gitconfig, gpg, symlinks, platform setup)
	./bootstrap

test: ## Run the test suite
	./test_dotfiles

status: ## Show dotfile symlink status
	@for f in ~/.bashrc ~/.zshrc ~/.gitconfig ~/.gitconfig.local ~/.gitignore; do \
		if [ -L "$$f" ]; then \
			printf "\033[32m%-25s -> %s\033[0m\n" "$$f" "$$(readlink "$$f")"; \
		elif [ -f "$$f" ]; then \
			printf "\033[33m%-25s (regular file, not linked!)\033[0m\n" "$$f"; \
		else \
			printf "\033[31m%-25s (missing)\033[0m\n" "$$f"; \
		fi; \
	done
