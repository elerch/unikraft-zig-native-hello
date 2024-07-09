const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

pub extern "c" fn gettid() std.c.pid_t;

export fn add(a: i32, b: i32) i32 {
    if (builtin.mode == .Debug) {
        const out = std.io.getStdErr().writer();
        out.print("WARNING: Building debug mode will likely crash in Unikraft environment. Use -Doptimize=ReleaseSafe\n", .{}) catch {};
    }
    if (builtin.mode != .Debug) {
        const out = std.io.getStdOut().writer();
        out.print("info: Built with a release build\n", .{}) catch {};
    }
    const out = std.io.getStdOut().writer();
    out.print("Hello from lib\n", .{}) catch {};
    std.log.err("logging error", .{});
    out.print("Checking thread id\n", .{}) catch {};
    out.print("WAT: {d}\n", .{gettid()}) catch {};
    out.print("Thread id: {d}\n", .{gettid()}) catch {};
    // out.print("Thread id: {d}\n", .{std.Thread.getCurrentId()}) catch {};
    // We have a theory we need posix-futex enabled for locking/unlocking
    // std.debug.print("debug print", .{});
    // if (builtin.single_threaded) @compileError("single threaded");
    return a + b + 1;
}

// Unhandled Trap 6 (invalid opcode), error code=0x0
//
// Thread.getCurrentId() calls fall flat. It looks like they use the linux
// call gettid, but that is not implemented by unikraft as of 0.17.0 (I
// believe). I tried adding process/thread support, but that did not address
// the problem. getCurrentId is used by the following:
//
// Mutex (only when building debug mode)
// Condition  (only when building in debug mode)
// std.debug panic implementation
//
// So:
// 1) don't call it ourselves
// 2) build in release mode
// 3) don't panic ;-)

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
