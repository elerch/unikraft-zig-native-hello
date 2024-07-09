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
code is all in the `ziggy` directory. This is all prototype level code at this
point.

Reproducibility
---------------

This build is not reproducible at the moment. The problem is that we need v0.17.0
or higher (this may be an issue with QEMU installed version, so YMMV). Kraftfile
is designed to pin to a specific version, but as of this writing, versions of
unikraft core post 0.16.1 are not listed in https://manifests.kraftkit.sh/unikraft.yaml,
and as a result cannot be used, so we are forced to use "stable" as the version.

undefined.c
-----------

This file aims to fill in all the undefined symbols that are referenced when
a zig project links libC (necessary for unikraft kernel development). However,
this is very incomplete. The `.config.hellowworld_qemu-x86_64` file, usually
managed by the invocation of the TUI started by `kraft menu`, will add/remove
features that result in various libc symbols being implemented. A few
`#ifdef` statements exist currently, but even the few that are in there aren't
quite right...this file is mostly a "hack around until it works" effort.

Knowing that this is an initial effort, care was put into making sure that
when a symbol is actually **used** at runtime, the unikernel will crash after
posting a message indicating the specific function call that was involved. This
is designed to either a) correct the configuration using `kraft menu` or
b) provide an implementation directly in `undefined.c`. In some cases, I prefer
the implementation in `undefined.c`, most specifically the `write` function,
which will output stderr messages in red.

Notes
-----


The build script basically runs these commands:

```sh
(cd ziggy && zig build)
LIBZIGGY=$(pwd)/ziggy/zig-out/lib/libziggy.a kraft build --plat qemu --arch x86_64 --log-level debug --log-type basic
kraft run --plat qemu --arch x86_64
```
