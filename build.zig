const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const ziggy = b.dependency("ziggy", .{
        .target = target,
        .optimize = optimize,
    });

    const install_step = b.getInstallStep();
    const build_cmd = b.addSystemCommand(&[_][]const u8{
        "kraft",
        "build",
        "--plat",
        "qemu",
        "--arch",
        "x86_64",
        "--log-level",
        "debug",
        // "--log-type",
        // "basic",
    });
    install_step.dependOn(&build_cmd.step);

    const artifact_env_var = LazyPathEnvironmentVariable.create(
        b,
        "LIB_ZIGGY",
        ziggy.artifact("libziggy").getEmittedBin(),
        build_cmd,
    );
    artifact_env_var.step.dependOn(&ziggy.artifact("libziggy").step);

    build_cmd.step.dependOn(&artifact_env_var.step);
    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "kraft",
        "run",
        "--plat",
        "qemu",
        "--arch",
        "x86_64",
    });

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(install_step);

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    var kraft_clean_cmd = b.addSystemCommand(&[_][]const u8{
        "kraft",
        "clean",
        "--plat",
        "qemu",
        "--arch",
        "x86_64",
    });
    kraft_clean_cmd.stdio = .{ .check = .{} }; // kraft clean has some weird exit code behavior
    kraft_clean_cmd.has_side_effects = true;
    const clean_step = b.step("clean", "Clean the unikraft build");
    clean_step.dependOn(&kraft_clean_cmd.step);

    const distclean_cmd = b.addSystemCommand(&[_][]const u8{
        "rm",
        "-rf",
        ".unikraft",
    });

    // rm -rf in this manner is leaving empty .unikraft/build, which is confusing
    // let's whack it
    const remove_empties_cmd = b.addSystemCommand(&[_][]const u8{
        "find", ".unikraft", "-type", "d", "-empty", "-delete",
    });
    remove_empties_cmd.step.dependOn(&distclean_cmd.step);

    const distclean_step = b.step("distclean", "Deep clean the unikraft build");
    distclean_step.dependOn(clean_step);
    distclean_step.dependOn(&remove_empties_cmd.step);
}

const LazyPathEnvironmentVariable = struct {
    const base_id: std.Build.Step.Id = .custom;

    step: std.Build.Step,

    lazy_path: std.Build.LazyPath,

    key: []const u8,

    run_step: *std.Build.Step.Run,

    pub fn create(
        owner: *std.Build,
        comptime key: []const u8,
        lazy_path: std.Build.LazyPath,
        run_step: *std.Build.Step.Run,
    ) *LazyPathEnvironmentVariable {
        const step = owner.allocator.create(LazyPathEnvironmentVariable) catch @panic("OOM");
        step.* = .{
            .step = std.Build.Step.init(.{
                .id = base_id,
                .name = "env var " ++ key,
                .owner = owner,
                .makeFn = make,
            }),
            .key = key,
            .lazy_path = lazy_path,
            .run_step = run_step,
        };
        return step;
    }

    fn make(step: *std.Build.Step, prog_node: std.Progress.Node) error{ MakeFailed, MakeSkipped }!void {
        _ = prog_node;
        const b = step.owner;
        // const arena = b.allocator;
        const this: *LazyPathEnvironmentVariable = @fieldParentPtr("step", step);
        this.run_step.setEnvironmentVariable(this.key, this.lazy_path.getPath2(b, &this.step));
    }
};
