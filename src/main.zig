const std = @import("std");

const xymonxhosts = @cImport({
    @cInclude("loadhosts.c");
});

pub fn main() void {
    const hosts = xymonxhosts.loadhosts();
    defer std.debug.print("Deallocating hosts\n");
    defer xymonxhosts.deallocate(hosts);
    for (hosts) |host| {
        std.debug.print("Host: {}\n", host.name);
    }
}
