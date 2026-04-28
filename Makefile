.PHONY: check check-skill check-docs check-adapt

check: check-skill check-docs check-adapt

check-skill:
	bash scripts/check_skill_contract.sh

check-docs:
	bash scripts/check_docs_sync.sh

check-adapt:
	bash scripts/check_adapt_contract.sh
