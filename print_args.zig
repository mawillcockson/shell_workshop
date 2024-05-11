// if Windows SDK is installed (through MSBuildTools, for instance), can be compiled with
// zig build-exe -O ReleaseSmall -fstrip -fsingle-threaded -target x86_64-windows-msvc -mcpu sandybridge print_args.zig
// upx --best --ultra-brute .\print_args.exe
// I'm not 100% sure if Windows SDK is needed, though.

const std = @import("std");

pub fn main() !void {
    // var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
    // defer arena.deinit();

    // const allocator = arena.allocator();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("memory leak");
    }

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();

    const stdout = std.io.getStdOut().writer();

    var i: u32 = 0;
    while (args_iter.next()) |*arg| : (i += 1) {
        try stdout.print("{d} ->{s}<-\n", .{ i, arg.* });
    }
}
