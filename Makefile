.PHONY: install dry-run minimal full validate uninstall lint

install:
	./install.sh

dry-run:
	./install.sh --dry-run

minimal:
	./install.sh --minimal

full:
	./install.sh --full

validate:
	./scripts/validate.sh

uninstall:
	./uninstall.sh

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck install.sh uninstall.sh scripts/*.sh packages/*.sh claude/install.sh i3/*.sh bash/*.bash; \
	else \
		echo "shellcheck not installed, skipping"; \
	fi
