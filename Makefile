SERIES = 0.52
VERSION = $(SERIES).0
PREFIX ?= /usr/local
DESTDIR ?=
SOURCE = $(sort $(wildcard src/*.vala))

all: build/valalint test

build/valalint: $(SOURCE)
	valac --save-temps -d build --pkg libvala-$(SERIES) --pkg gio-2.0 -X '-DVALALINT_VERSION="$(VERSION)"' \
	-X -g3 -o valalint $(SOURCE)
	build/valalint --dump-tree $(SOURCE)

build/valalint-tests: tests/Test.vala
	valac  --save-temps -d build --pkg gio-2.0 -o valalint-tests tests/Test.vala

test: build/valalint-tests build/valalint
	build/valalint-tests --verbose

install: build/valalint
	install -Dv build/valalint "$(DESTDIR)$(PREFIX)/bin/valalint"

clean:
	rm -rf build
