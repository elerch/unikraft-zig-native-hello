Native Unikraft Microkernel Build for Zig libraries
===================================================

This is an example repository, due to be cleaned up. For now, install Kraftkit
and zig and build it this way:

```sh
(cd ziggy && zig build -Doptimize=ReleaseSafe -Dtarget=x86_64-linux-gnu.2.13 -Dcpu=baseline) && cp ziggy/zig-out/lib/libziggy.a . &&  kraft build --plat qemu --arch x86_64 --log-level debug --log-type basic && kraft run --plat qemu --arch x86_64
```

Only works on Linux, with QEMU (install that too!) and Zig 0.13.0 (though probably
works on 0.12.0 as well).

More to follow
