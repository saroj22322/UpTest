.DEFAULT_GOAL:=help

.PHONY: pre-commit-install 
pre-commit-install: install ## Install the pre-commit app and activate it for the repository

.PHONY: pre-commit-report
pre-commit-report: report ## Generate report using pre-commit

.PHONY: docker-entry
docker-entry: docker-install pause

.PHONY: install
install: 
	@chmod +x ./.pre-commits/pre-commit-install.sh;
	@sudo sh ./.pre-commits/pre-commit-install.sh;

.PHONY: docker-install
docker-install: 
	@chmod +x ./.pre-commits/pre-commit-install.sh;
	@sh ./.pre-commits/pre-commit-install.sh;

.PHONY: report
report:
	@chmod +x ./.pre-commits/pre-commit-report.sh
	@sh ./.pre-commits/pre-commit-report.sh

.PHONY: pause
pause:
	@tail -f /dev/null
	
	
.PHONY: help
help: ## Show this help message.
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo