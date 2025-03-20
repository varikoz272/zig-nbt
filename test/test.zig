const std = @import("std");
const nbt = @import("nbt");

test "encode and write compound tag with all types" {
    const allocator = std.testing.allocator;

    // Create a compound tag with nested tags
    var compound_tags = std.ArrayList(nbt.Tag).init(allocator);
    defer compound_tags.deinit();

    try compound_tags.append(nbt.Tag.init("byte", .{ .Byte = 42 }));
    try compound_tags.append(nbt.Tag.init("short", .{ .Short = 1234 }));
    try compound_tags.append(nbt.Tag.init("int", .{ .Int = 123456 }));
    try compound_tags.append(nbt.Tag.init("long", .{ .Long = 1234567890123456 }));
    try compound_tags.append(nbt.Tag.init("float", .{ .Float = 3.14 }));
    try compound_tags.append(nbt.Tag.init("double", .{ .Double = 2.718281828459045 }));

    // Fix for ByteArray
    var byte_array = [_]u8{ 1, 2, 3, 4 };
    try compound_tags.append(nbt.Tag.init("byte_array", .{ .ByteArray = &byte_array }));

    try compound_tags.append(nbt.Tag.init("string", .{ .String = "Hello, NBT!" }));

    // Create a list of Byte tags
    var list_tags = std.ArrayList(nbt.Tag).init(allocator);
    defer list_tags.deinit();
    try list_tags.append(nbt.Tag.init("", .{ .Byte = 1 }));
    try list_tags.append(nbt.Tag.init("", .{ .Byte = 2 }));
    try list_tags.append(nbt.Tag.init("", .{ .Byte = 3 }));
    try compound_tags.append(nbt.Tag.init("list", .{ .List = list_tags }));

    // Fix for IntArray
    var int_array = [_]i32{ 1, 2, 3, 4 };
    try compound_tags.append(nbt.Tag.init("int_array", .{ .IntArray = &int_array }));

    // Fix for LongArray
    var long_array = [_]i64{ 1, 2, 3, 4 };
    try compound_tags.append(nbt.Tag.init("long_array", .{ .LongArray = &long_array }));

    // Create a nested compound tag
    var nested_compound_tags = std.ArrayList(nbt.Tag).init(allocator);
    defer nested_compound_tags.deinit();
    try nested_compound_tags.append(nbt.Tag.init("nested_byte", .{ .Byte = 99 }));
    try nested_compound_tags.append(nbt.Tag.init("nested_string", .{ .String = "Nested Hello!" }));
    try compound_tags.append(nbt.Tag.init("nested_compound", .{ .Compound = &nested_compound_tags }));

    var root_tag = nbt.Tag.init("root", .{ .Compound = &compound_tags });

    // Encode the root tag
    const encoded_data = try root_tag.encode(allocator);
    defer allocator.free(encoded_data);

    // Write the encoded data to a file
    try nbt.write(encoded_data, "test.nbt");

    // Verify the file exists
    const file = try std.fs.cwd().openFile("test.nbt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    std.debug.print("File size: {} bytes\n", .{file_size});
    try std.testing.expect(file_size > 0);
}
