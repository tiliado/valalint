all:
	valac --save-temps -d build --pkg libvala-0.36 --pkg gio-2.0 -o valalint src/*.vala
	build/valalint --pkg libvala-0.36 --pkg gio-2.0 src/*.vala
