test:
	zig test src/main.zig
build:
	zig build
run:
	time zig run src/main.zig && cp canvas.ppm /mnt/c/Users/photo/Desktop
copy_out:
	cp canvas.ppm /mnt/c/Users/photo/Desktop
