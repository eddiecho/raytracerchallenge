test:
	find src -name "*.zig" -not -path "*zig-cache*" -exec zig test {} \;

build:
	zig build
run:
	zig run src/main.zig && cp canvas.ppm /mnt/c/Users/photo/Desktop
copy_out:
	cp canvas.ppm /mnt/c/Users/photo/Desktop
