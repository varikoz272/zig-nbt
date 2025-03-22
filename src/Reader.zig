const std = @import("std");
const Allocator = std.mem.Allocator;

const nbt = @import("nbt.zig");

pub fn readTag(reader: anytype, allocator: Allocator) !nbt.Tag {
    const type_byte = try reader.readByte();
    const tag_type: nbt.TagType = @enumFromInt(type_byte);

    if (tag_type == .End) return nbt.Tag.End();

    const name_len = try reader.readInt(u16, .big);
    const name: []u8 = try allocator.alloc(u8, name_len);
    if (name.len > 0) try reader.readNoEof(name);

    var tag = nbt.Tag.init(name, undefined);

    tag.value = switch (tag_type) {
        .ByteArray => blk: {
            const array_len = try reader.readInt(i32, .big);
            if (array_len == 0) break :blk nbt.TagValue{ .ByteArray = &[_]u8{} };

            const array = try allocator.alloc(u8, @intCast(array_len));
            try reader.readNoEof(array);

            break :blk nbt.TagValue{ .ByteArray = array };
        },
        .String => blk: {
            const string_len = try reader.readInt(u16, .big);
            if (string_len == 0) break :blk nbt.TagValue{ .String = &[_]u8{} };

            const string = try allocator.alloc(u8, @intCast(string_len));
            try reader.readNoEof(string);

            break :blk nbt.TagValue{ .String = string };
        },

        .List => blk: {
            const list_type: nbt.TagType = @enumFromInt(try reader.readByte());

            const list_len = try reader.readInt(i32, .big);
            if (list_len == 0) break :blk nbt.TagValue{ .List = std.ArrayList(nbt.TagValue).init(allocator) };

            var list = try std.ArrayList(nbt.TagValue).initCapacity(allocator, @intCast(list_len));
            for (0..@intCast(list_len)) |_| try list.append(try readTagValue(reader, list_type, allocator));

            break :blk nbt.TagValue{ .List = list };
        },

        .Compound => blk: {
            var compound = std.ArrayList(nbt.Tag).init(allocator);
            var inner_tag: nbt.Tag = try readTag(reader, allocator);
            while (inner_tag.value != .End) : (inner_tag = try readTag(reader, allocator))
                try compound.append(inner_tag);

            try compound.append(nbt.Tag.End());
            break :blk nbt.TagValue{ .Compound = compound };
        },

        .IntArray => blk: {
            const array_len = try reader.readInt(i32, .big);
            if (array_len == 0) break :blk nbt.TagValue{ .IntArray = &[_]i32{} };

            const array = try allocator.alloc(i32, @intCast(array_len));
            for (array) |*int_tag| int_tag.* = try reader.readInt(i32, .big);

            break :blk nbt.TagValue{ .IntArray = array };
        },

        .LongArray => blk: {
            const array_len = try reader.readInt(i32, .big);
            if (array_len == 0) break :blk nbt.TagValue{ .LongArray = &[_]i64{} };

            const array = try allocator.alloc(i64, @intCast(array_len));
            for (array) |*long_tag| long_tag.* = try reader.readInt(i64, .big);

            break :blk nbt.TagValue{ .LongArray = array };
        },
        .End => unreachable,
        else => try readTagValue(reader, tag_type, allocator),
    };

    return tag;
}

pub fn readTagValue(reader: anytype, tag_type: nbt.TagType, allocator: Allocator) !nbt.TagValue {
    return switch (tag_type) {
        .Byte => nbt.TagValue{ .Byte = try reader.readByte() },
        .Short => nbt.TagValue{ .Short = try reader.readInt(i16, .big) },
        .Int => nbt.TagValue{ .Int = try reader.readInt(i32, .big) },
        .Long => nbt.TagValue{ .Long = try reader.readInt(i64, .big) },
        .Float => nbt.TagValue{ .Float = @bitCast(try reader.readInt(u32, .big)) },
        .Double => nbt.TagValue{ .Double = @bitCast(try reader.readInt(u64, .big)) },
        .ByteArray => blk: {
            const len = try reader.readInt(i32, .big);
            if (len == 0) return nbt.TagValue{ .End = {} };

            const array = try allocator.alloc(u8, @intCast(len));
            try reader.readNoEof(array);
            break :blk nbt.TagValue{ .ByteArray = array };
        },
        .String => blk: {
            const len = try reader.readInt(u16, .big);
            if (len == 0) return nbt.TagValue{ .End = {} };

            const string = try allocator.alloc(u8, @intCast(len));
            try reader.readNoEof(string);
            break :blk nbt.TagValue{ .String = string };
        },
        .IntArray => blk: {
            const len = try reader.readInt(i32, .big);
            if (len == 0) return nbt.TagValue{ .End = {} };

            const array = try allocator.alloc(i32, @intCast(len));
            for (array) |*int| int.* = try reader.readInt(i32, .big);
            break :blk nbt.TagValue{ .IntArray = array };
        },
        .LongArray => blk: {
            const len = try reader.readInt(i32, .big);
            if (len == 0) return nbt.TagValue{ .End = {} };

            const array = try allocator.alloc(i64, @intCast(len));
            for (array) |*long| long.* = try reader.readInt(i64, .big);
            break :blk nbt.TagValue{ .LongArray = array };
        },
        .End => nbt.TagValue{ .End = {} },
        else => unreachable,
    };
}

const Settings = struct {
    buffer_size: usize = 8192,
    panic_on_buffer_overflow: bool = true,

    pub fn init(buffer_size: usize, panic_on_buffer_overflow: bool) @This() {
        return @This(){
            .buffer_size = buffer_size,
            .panic_on_buffer_overflow = panic_on_buffer_overflow,
        };
    }
};
