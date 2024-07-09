Native Unikraft Microkernel Build for Zig libraries
===================================================


Building
--------

Everything assumes Linux on x86_64, though some trivial changes should allow
aarch64. Install the following:

* [Zig](https://ziglang.org). Versions 0.12.0 and 0.13.0 should work
* [QEMU](https://www.qemu.org/download/#linux)
* [Kraftkit](https://unikraft.org/docs/cli/install)

Then run `zig build run` and everything will compile and run. The zig source
code is all in the `ziggy` directory



Notes
-----

The build script basically runs these commands:

```sh
(cd ziggy && zig build)
LIBZIGGY=$(pwd)/ziggy/zig-out/lib/libziggy.a kraft build --plat qemu --arch x86_64 --log-level debug --log-type basic
kraft run --plat qemu --arch x86_64
```
