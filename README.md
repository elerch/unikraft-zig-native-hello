(cd ziggy && zig build -Doptimize=ReleaseSafe -Dtarget=x86_64-linux-gnu.2.13 -Dcpu=baseline) && cp ziggy/zig-out/lib/libziggy.a . &&  kraft build --plat qemu --arch x86_64 --log-level debug --log-type basic && kraft run --pla
t qemu --arch x86_64
