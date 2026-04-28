.PHONY: check check-skill check-docs check-adapt check-openclaw check-hermes check-cursor check-claude

check: check-skill check-docs check-adapt check-openclaw check-hermes check-cursor check-claude

check-skill:
	bash scripts/check_skill_contract.sh

check-docs:
	bash scripts/check_docs_sync.sh

check-adapt:
	bash scripts/check_adapt_contract.sh

check-openclaw:
	bash scripts/check_openclaw_profile.sh

check-hermes:
	bash scripts/check_hermes_profile.sh

check-cursor:
	bash scripts/check_cursor_profile.sh

check-claude:
	bash scripts/check_claude_profile.sh
