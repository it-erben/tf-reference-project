.PHONY: check init-check fmt validate lint test
.NOTPARALLEL:

TFLINT ?= tflint

check: init-check fmt validate lint test

init-check:
	terraform init -backend=false -input=false

fmt:
	terraform fmt -check -recursive

validate:
	terraform validate

lint:
	$(TFLINT) --init
	$(TFLINT) --recursive

test:
	terraform test
