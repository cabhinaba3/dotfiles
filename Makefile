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
	@command -v shellcheck >/dev/null 2>&1 && shellcheck install.sh uninstall.sh scripts/*.sh packages/*.sh claude/install.sh \
		|| echo "shellcheck not installed, skipping"
