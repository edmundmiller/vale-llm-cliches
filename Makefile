VALE_VERSION := 3.19.0
VALE := .bin/vale

.PHONY: bootstrap build test clean

bootstrap:
	./scripts/bootstrap-vale.sh $(VALE_VERSION)

build:
	python3 scripts/build.py

test: bootstrap build
	VALE_BIN=$(VALE) ./scripts/test.sh

clean:
	rm -rf .bin build styles
