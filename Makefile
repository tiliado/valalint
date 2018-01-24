all:
	valac --save-temps -d build --pkg libvala-0.38 --pkg gio-2.0 -o valalint src/*.vala
	build/valalint --dump-tree --pkg libvala-0.38 --pkg gio-2.0 src/*.vala
	valac  --save-temps -d build --pkg gio-2.0 -o valalint-tests tests/Test.vala && build/valalint-tests --verbose
