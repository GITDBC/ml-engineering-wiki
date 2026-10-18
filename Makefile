.PHONY: clean-cache-temp-files \
		setup \
		format \
		doc  \
		all

.DEFAULT_GOAL := all

DOCS_PATH ?= docs

clean-cache-temp-files:
	@echo "Cleaning cache and temporary files..."
	@find . -type d -name __pycache__ -exec rm -rf {} +
	@find . -type d -name .pytest_cache -exec rm -rf {} +
	@find . -type d -name .mypy_cache -exec rm -rf {} +
	@find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
	@echo "✅ Clean complete."

setup:
	@echo "Installing dependencies..."
	@uv sync --all-extras
	@echo "✅ Dependencies installed."

format:
	@echo "Formatting documents..."
	@npx prettier --write $(DOCS_PATH)
	@echo "✅ Formatting complete."

doc:
	@echo "Serving documentation..."
	@uv run zensical serve

all: clean-cache-temp-files setup format 
	@echo "✅ All tasks complete."