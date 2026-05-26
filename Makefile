.DEFAULT_GOAL := help
.PHONY: help \
        local-install local-freeze \
        local-db-init \
        local-run \
        local-lint \
        local-test \
        local-clean

PYTHON     := ./venv/bin/python
PIP        := ./venv/bin/pip
PRECOMMIT  := ./venv/bin/pre-commit

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-22s %s\n", $$1, $$2}'

local-install:  ## Create venv (if missing), install runtime + dev deps, install pre-commit hooks
	test -d venv || python3 -m venv venv
	$(PIP) install -r requirements-dev.txt
	$(PRECOMMIT) install

local-freeze:  ## Write current venv package versions to requirements.txt
	$(PIP) freeze > requirements.txt

local-db-init:  ## Create the SQLite database file and tables
	$(PYTHON) -m flask --app app init-db

local-run:  ## Run the Flask dev server on localhost:5000
	$(PYTHON) app.py

local-lint:  ## Run pre-commit hooks against all tracked files
	$(PRECOMMIT) run --all-files

local-test:  ## Run pytest test suite
	$(PYTHON) -m pytest

local-clean:  ## Remove __pycache__ dirs
	find . -type d -name __pycache__ -not -path './venv/*' -exec rm -rf {} +
