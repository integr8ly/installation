
.PHONY: test/format
test/format:
	@./test/format.sh

.PHONY: test/install
test/install:
	@./test/install.sh

.PHONY: test/upgrade
test/upgrade:
	@./test/upgrade.sh
