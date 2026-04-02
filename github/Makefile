ROOT     := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
DESC     := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/commit_description.txt)
BRANCH   := main
REMOTE   := origin

.PHONY: help push pull commit status log

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  push    - Stage all, commit with message from commit_description.txt, and push"
	@echo "  pull    - Pull latest changes from remote"
	@echo "  commit  - Stage all and commit with message from commit_description.txt"
	@echo "  status  - Show git status"
	@echo "  log     - Show last 10 commits"

commit:
	@test -f "$(DESC)" || { echo "Error: commit_description.txt not found at $(DESC)"; exit 1; }
	@MSG=$$(cat "$(DESC)"); \
	test -n "$$MSG" || { echo "Error: commit_description.txt is empty"; exit 1; }; \
	cd "$(ROOT)" && git add -A && git commit -m "$$MSG"

push: commit
	cd "$(ROOT)" && git push $(REMOTE) $(BRANCH)

pull:
	cd "$(ROOT)" && git pull $(REMOTE) $(BRANCH)

status:
	cd "$(ROOT)" && git status

log:
	cd "$(ROOT)" && git log --oneline -10
