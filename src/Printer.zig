const std = @import("std");
const nbt = @import("nbt.zig");

const Allocator = std.mem.Allocator;

/// Prints given tag in a tree way
pub fn print(self: nbt.Tag, start_tabs_count: usize) void {
    std.debug.print("\n", .{});

    for (0..start_tabs_count) |_| {
        std.debug.print("   ", .{});
    }

    switch (self.value) {
        .End => std.debug.print("*end*", .{}), // No data for End
        .Byte => std.debug.print("(Byte) {s}: {d}", .{ self.name, self.value.Byte }),
        .Short => std.debug.print("(Short) {s}: {d}", .{ self.name, self.value.Short }),
        .Int => std.debug.print("(Int) {s}: {d}", .{ self.name, self.value.Int }),
        .Long => std.debug.print("(Long) {s}: {d}", .{ self.name, self.value.Long }),
        .Float => std.debug.print("(Float) {s}: {e}", .{ self.name, self.value.Float }),
        .Double => std.debug.print("(Double) {s}: {e}", .{ self.name, self.value.Double }),
        .ByteArray => {
            std.debug.print("(ByteArray) {s}:", .{self.name});
            for (self.value.ByteArray) |byte_value| {
                print(nbt.Tag.init("", .{ .Byte = byte_value }), start_tabs_count + 1);
            }
        },
        .String => std.debug.print("(String) {s}: {s}", .{ self.name, self.value.String }),
        .List => {
            std.debug.print("(List) {s}:", .{self.name});

            if (self.value.List.items.len == 0) {
                print(nbt.Tag.init("", .{ .End = {} }), start_tabs_count + 1);
            } else {
                for (self.value.List.items) |tag_value|
                    printValue(tag_value, start_tabs_count + 1);
            }
        },
        .Compound => {
            std.debug.print("(Compound) {s}:", .{self.name});

            if (self.value.Compound.items.len == 0) {
                print(nbt.Tag.init("", .{ .End = {} }), start_tabs_count + 1);
            } else {
                for (self.value.Compound.items) |tag|
                    print(tag, start_tabs_count + 1);
            }
        },
        .IntArray => {
            std.debug.print("(IntArray) {s}:", .{self.name});

            if (self.value.IntArray.len == 0) {
                print(nbt.Tag.init("", .{ .End = {} }), start_tabs_count + 1);
            } else {
                for (self.value.IntArray) |tag_value|
                    print(nbt.Tag.init("", .{ .Int = tag_value }), start_tabs_count + 1);
            }
        },
        .LongArray => {
            std.debug.print("(LongArray) {s}:", .{self.name});

            if (self.value.LongArray.len == 0) {
                print(nbt.Tag.init("", .{ .End = {} }), start_tabs_count + 1);
            } else {
                for (self.value.LongArray) |tag_value|
                    print(nbt.Tag.init("", .{ .Long = tag_value }), start_tabs_count + 1);
            }
        },
    }
}

pub fn printValue(value: nbt.TagValue, start_tabs_count: usize) void {
    print(nbt.Tag.init("", value), start_tabs_count);
}
