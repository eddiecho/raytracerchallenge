test:
	find src -name "*.zig" -not -path "*zig-cache*" -exec zig test {} \;
