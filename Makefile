.PHONY: install

install:
	mkdir -p $(prefix)/
	cp -r bin $(prefix)/bin
	cp -r lib $(prefix)/lib
	cp -r share $(prefix)/share
