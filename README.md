# zig-nbt (in development)

an nbt lib and module in pure zig without dependencies other than std

## purpose

this library is done mainly for litematica files. the goal is minimalism and speed

## features

- ❌gzip
- standart nbt files (❌reading, ✅writing)
- ❌litematica files
- ❌region files

## requirements

system requirements and dependencies
- zig 0.14.0
- processor

## how to use

1. fetch into your project:
```
zig fetch --save git+https://github.com/varikoz272/zig-nbt
```

2. add to build.zig:
```
const nbt = b.dependency("nbt", .{});
your_compile_that_needs_nbt.root_module.addImport("nbt", nbt.module("nbt"));
```

3. check test/test.zig to learn the usage
