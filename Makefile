ifeq ($(prefix),)
	prefix=/usr
endif

.PHONY: install

install:
	/bin/bash ./install.sh "$(prefix)"
