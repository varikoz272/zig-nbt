const std = @import("std");
const Allocator = std.mem.Allocator;

/// Represents all possible data tags used by NBT.
/// The value of the enum is a byte that gets placed before the actual value in NBT encoding.
pub const TagType = enum(u8) {
    End = 0x00,
    Byte = 0x01,
    Short = 0x02,
    Int = 0x03,
    Long = 0x04,
    Float = 0x05,
    Double = 0x06,
    ByteArray = 0x07,
    String = 0x08,
    List = 0x09,
    Compound = 0x0A,
    IntArray = 0x0B,
    LongArray = 0x0C,
};

/// Represents all possible data tags used by NBT with Zig data types.
/// Compatible with Java types.
pub const TagValue = union(TagType) {
    const Self = @This();

    End: void,
    Byte: u8,
    Short: i16,
    Int: i32,
    Long: i64,
    Float: f32,
    Double: f64,
    ByteArray: []u8,
    String: []const u8,
    List: std.ArrayList(Tag),
    Compound: *std.ArrayList(Tag),
    IntArray: []i32,
    LongArray: []i64,
};

pub const Tag = struct {
    const Self = @This();

    name: []const u8,
    value: TagValue,

    pub fn init(name: []const u8, value: TagValue) Self {
        return Self{
            .name = name,
            .value = value,
        };
    }

    /// Encodes the tag into NBT format.
    pub fn encode(self: Self, allocator: Allocator) ![]u8 {
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();

        try self.encodeToBuffer(&buffer);
        return buffer.toOwnedSlice();
    }

    fn encodeToBuffer(self: Self, buffer: *std.ArrayList(u8)) !void {
        // Write tag type
        try buffer.append(@intFromEnum(self.value));
        // Write name length (as big-endian u16)
        const writer = buffer.writer();
        try writer.writeInt(u16, @intCast(self.name.len), .big);
        // Write name
        try buffer.appendSlice(self.name);
        // Write value
        switch (self.value) {
            .End => {}, // No data for End
            .Byte => |v| try buffer.append(v),
            .Short => |v| try writer.writeInt(i16, v, .big),
            .Int => |v| try writer.writeInt(i32, v, .big),
            .Long => |v| try writer.writeInt(i64, v, .big),
            .Float => |v| try writer.writeInt(u32, @bitCast(v), .big),
            .Double => |v| try writer.writeInt(u64, @bitCast(v), .big),
            .ByteArray => |v| {
                try writer.writeInt(i32, @intCast(v.len), .big);
                try buffer.appendSlice(v);
            },
            .String => |v| {
                try writer.writeInt(u16, @intCast(v.len), .big);
                try buffer.appendSlice(v);
            },
            .List => |v| {
                if (v.items.len == 0) {
                    // Empty list: write type End and length 0
                    try buffer.append(@intFromEnum(TagType.End));
                    try writer.writeInt(i32, 0, .big);
                } else {
                    // Write list type (based on the first element)
                    const list_type = @intFromEnum(v.items[0].value);
                    try buffer.append(list_type);
                    // Write list length
                    try writer.writeInt(i32, @intCast(v.items.len), .big);
                    // Write list items (values only!)
                    for (v.items) |item| {
                        switch (item.value) {
                            .Byte => |val| try buffer.append(val),
                            .Short => |val| try writer.writeInt(i16, val, .big),
                            .Int => |val| try writer.writeInt(i32, val, .big),
                            .Long => |val| try writer.writeInt(i64, val, .big),
                            .Float => |val| try writer.writeInt(u32, @bitCast(val), .big),
                            .Double => |val| try writer.writeInt(u64, @bitCast(val), .big),
                            .ByteArray => |val| {
                                try writer.writeInt(i32, @intCast(val.len), .big);
                                try buffer.appendSlice(val);
                            },
                            .String => |val| {
                                try writer.writeInt(u16, @intCast(val.len), .big);
                                try buffer.appendSlice(val);
                            },
                            .IntArray => |val| {
                                try writer.writeInt(i32, @intCast(val.len), .big);
                                for (val) |x| try writer.writeInt(i32, x, .big);
                            },
                            .LongArray => |val| {
                                try writer.writeInt(i32, @intCast(val.len), .big);
                                for (val) |x| try writer.writeInt(i64, x, .big);
                            },
                            else => @panic("Unsupported list element type"),
                        }
                    }
                }
            },
            .Compound => |v| {
                for (v.items) |tag| {
                    try tag.encodeToBuffer(buffer);
                }
                // Write End tag to signify end of compound
                try buffer.append(@intFromEnum(TagType.End));
            },
            .IntArray => |v| {
                try writer.writeInt(i32, @intCast(v.len), .big);
                for (v) |item| {
                    try writer.writeInt(i32, item, .big);
                }
            },
            .LongArray => |v| {
                try writer.writeInt(i32, @intCast(v.len), .big);
                for (v) |item| {
                    try writer.writeInt(i64, item, .big);
                }
            },
        }
    }
};

/// Writes the encoded NBT data to a file.
pub fn write(data: []const u8, file_path: []const u8) !void {
    var file = try std.fs.cwd().createFile(file_path, .{});
    defer file.close();

    try file.writeAll(data);
}
