ifeq ($(OS),Windows_NT)
	SCRIPT_DIR = Scripts
	SYS_SHELL = cmd /C
else
	SCRIPT_DIR = bin
	SYS_SHELL = bash -c
endif

PROJECT_NAME = clac
VENV_ROOT = $(WORKON_HOME)/$(PROJECT_NAME)
VENV_SCRIPTS = $(VENV_ROOT)/$(SCRIPT_DIR)
VENV_PYTHON = $(VENV_SCRIPTS)/python
VENV_LINTER = $(VENV_SCRIPTS)/pylint
VENV_TYPECHKR = $(VENV_SCRIPTS)/mypy
VENV_PYTEST = $(VENV_SCRIPTS)/pytest
VENV_SPHINX = $(VENV_SCRIPTS)/sphinx-build
VENV_PIP = $(VENV_PYTHON) -m pip

install: .venv
	$(VENV_PIP) install -e .

install-dev: install
	$(VENV_PIP) install -e .[fulldev]

unvenv:
	-deactivate
	rm -rf ./$(PROJECT_NAME).egg-info
	rm -rf $(VENV_ROOT)
	rm -f .venv

$(VENV_PYTHON):
	$(SYS_SHELL) "python -m venv $(VENV_ROOT)"
	$(VENV_PIP) install --upgrade pip setuptools

$(VENV_LINTER): .venv
	$(VENV_PIP) install -e.[lint]

$(VENV_PYTEST): .venv
	$(VENV_PIP) install -e.[test,cov]

$(VENV_SPHINX): .venv
	$(VENV_PIP) install -e.[docs]

.venv: $(VENV_PYTHON)
	echo $(VENV_PYTHON) > .venv

clean:
	git clean -dxfe "*.egg-info" -e ".idea" -e ".vscode" -e "*.komodoproject" -e ".venv"

lint: $(VENV_LINTER)
	$(VENV_LINTER) $(PROJECT_NAME)
	$(VENV_TYPECHKR) $(PROJECT_NAME)

test: $(VENV_PYTEST)
	$(VENV_PYTEST) --cov $(PROJECT_NAME) tests
	$(VENV_PYTHON) -m coverage html

docs: $(VENV_SPHINX)
	$(VENV_SPHINX) -M html docs/source docs/build

.PHONY: install unvenv docs test lint clean install-dev