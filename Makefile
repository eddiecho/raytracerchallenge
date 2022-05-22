test:
	find src -name "*.zig" -not -path "*zig-cache*" -exec zig test {} \;

build:
	zig build
run:
	zig run src/main.zig
copy_out:
	cp canvas.ppm /mnt/c/Users/photo/Desktop
