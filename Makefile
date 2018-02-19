VERSION = 0.38.0
PREFIX ?= /usr/local
DESTDIR ?=
SOURCE = $(sort $(wildcard src/*.vala))

all: build/valalint test

build/valalint: $(SOURCE)
	valac --save-temps -d build --pkg libvala-0.38 --pkg gio-2.0 -X '-DVALALINT_VERSION="$(VERSION)"' \
	-o valalint $(SOURCE)
	build/valalint --dump-tree $(SOURCE)

build/valalint-tests: tests/Test.vala
	valac  --save-temps -d build --pkg gio-2.0 -o valalint-tests tests/Test.vala

test: build/valalint-tests build/valalint
	build/valalint-tests --verbose

install: build/valalint
	install -Dv build/valalint "$(DESTDIR)$(PREFIX)/bin"
