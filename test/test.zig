const std = @import("std");
const nbt = @import("nbt");

// test "encode and write compound tag" {
//     const allocator = std.testing.allocator;
//
//     // Create a compound tag with nested tags
//     var compound_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer compound_tags.deinit();
//
//     try compound_tags.append(nbt.Tag.init("byte", .{ .Byte = 42 }));
//     try compound_tags.append(nbt.Tag.init("short", .{ .Short = 1234 }));
//     try compound_tags.append(nbt.Tag.init("int", .{ .Int = 123456 }));
//     try compound_tags.append(nbt.Tag.init("long", .{ .Long = 1234567890123456 }));
//     try compound_tags.append(nbt.Tag.init("float", .{ .Float = 3.14 }));
//     try compound_tags.append(nbt.Tag.init("double", .{ .Double = 2.718281828459045 }));
//
//     var byte_array = [_]u8{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("byte_array", .{ .ByteArray = &byte_array }));
//
//     try compound_tags.append(nbt.Tag.init("string", .{ .String = "Hello, NBT!" }));
//
//     var list_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer list_tags.deinit();
//     try list_tags.append(nbt.Tag.init("", .{ .Byte = 1 }));
//     try list_tags.append(nbt.Tag.init("", .{ .Byte = 2 }));
//     try list_tags.append(nbt.Tag.init("", .{ .Byte = 3 }));
//     try compound_tags.append(nbt.Tag.init("list", .{ .List = list_tags }));
//
//     var int_array = [_]i32{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("int_array", .{ .IntArray = &int_array }));
//
//     var long_array = [_]i64{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("long_array", .{ .LongArray = &long_array }));
//
//     var nested_compound_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer nested_compound_tags.deinit();
//     try nested_compound_tags.append(nbt.Tag.init("nested_byte", .{ .Byte = 99 }));
//     try nested_compound_tags.append(nbt.Tag.init("nested_string", .{ .String = "Nested Hello!" }));
//     try compound_tags.append(nbt.Tag.init("nested_compound", .{ .Compound = &nested_compound_tags }));
//
//     var root_tag = nbt.Tag.init("root", .{ .Compound = &compound_tags });
//
//     // Encode and write to file
//     const encoded_data = try root_tag.encode(allocator);
//     defer allocator.free(encoded_data);
//     try nbt.write(encoded_data, "test_write.nbt");
//
//     // Verify the file exists
//     const file = try std.fs.cwd().openFile("test_write.nbt", .{});
//     defer file.close();
//     try std.testing.expect((try file.getEndPos()) > 0);
// }
//
// test "encode and write light compound tag" {
//     const allocator = std.testing.allocator;
//
//     // Create a compound tag with nested tags
//     var compound_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer compound_tags.deinit();
//
//     try compound_tags.append(nbt.Tag.init("the int", .{ .Int = 123456 }));
//     var root_tag = nbt.Tag.init("root", .{ .Compound = &compound_tags });
//
//     // Encode and write to file
//     const encoded_data = try root_tag.encode(allocator);
//     defer allocator.free(encoded_data);
//     try nbt.write(encoded_data, "light_test_write.nbt");
//
//     // Verify the file exists
//     const file = try std.fs.cwd().openFile("light_test_write.nbt", .{});
//     defer file.close();
//     try std.testing.expect((try file.getEndPos()) > 0);
// }

// test "read compound tag" {
//     const allocator = std.testing.allocator;
//
//     // Read the encoded data from the file
//     const file = try std.fs.cwd().openFile("light_test_write.nbt", .{});
//     defer file.close();
//     const file_size = try file.getEndPos();
//     const encoded_data = try allocator.alloc(u8, file_size);
//     defer allocator.free(encoded_data);
//
//     // Use the file's reader to read all data
//     const reader = file.reader();
//     try reader.readNoEof(encoded_data);
//
//     // Decode the data
//     const decoded_tag = try nbt.Reader.read(encoded_data, allocator);
//     defer {
//         if (decoded_tag.value == .Compound) {
//             for (decoded_tag.value.Compound.items) |tag| {
//                 switch (tag.value) {
//                     .ByteArray => |v| allocator.free(v),
//                     .String => |v| allocator.free(v),
//                     .IntArray => |v| allocator.free(v),
//                     .LongArray => |v| allocator.free(v),
//                     .List => |v| v.deinit(),
//                     .Compound => |v| {
//                         for (v.items) |_| allocator.destroy(v);
//                         v.deinit();
//                     },
//                     else => {},
//                 }
//             }
//             decoded_tag.value.Compound.deinit();
//             allocator.destroy(decoded_tag.value.Compound);
//         }
//     }
//
//     // Verify the root tag
//     try std.testing.expectEqualStrings("root", decoded_tag.name);
//     try std.testing.expect(decoded_tag.value == .Compound);
// }

test "read light" {
    const file = try std.fs.cwd().openFile("chess_copy", .{});
    defer file.close();

    var file_buffer: [8196 * 400]u8 = undefined;
    const file_len = try file.readAll(&file_buffer);

    var stream = std.io.fixedBufferStream(file_buffer[0..file_len]);
    const reader = stream.reader();

    var buffer: [8196 * 400]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const tag = try nbt.Reader.readTag(reader, fba.allocator());
    nbt.Printer.print(tag, 0);
}

// test "print light" {
//     const allocator = std.testing.allocator;
//
//     // Create a compound tag with nested tags
//     var compound_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer compound_tags.deinit();
//
//     try compound_tags.append(nbt.Tag.init("byte", .{ .Byte = 42 }));
//     try compound_tags.append(nbt.Tag.init("short", .{ .Short = 1234 }));
//     try compound_tags.append(nbt.Tag.init("int", .{ .Int = 123456 }));
//     try compound_tags.append(nbt.Tag.init("long", .{ .Long = 1234567890123456 }));
//     try compound_tags.append(nbt.Tag.init("float", .{ .Float = 3.14 }));
//     try compound_tags.append(nbt.Tag.init("double", .{ .Double = 2.718281828459045 }));
//
//     var byte_array = [_]u8{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("byte_array", .{ .ByteArray = &byte_array }));
//
//     try compound_tags.append(nbt.Tag.init("string", .{ .String = "Hello, NBT!" }));
//
//     var list_tags = std.ArrayList(nbt.TagValue).init(allocator);
//     defer list_tags.deinit();
//     try list_tags.append(nbt.TagValue{ .Byte = 1 });
//     try list_tags.append(nbt.TagValue{ .Byte = 2 });
//     try list_tags.append(nbt.TagValue{ .Byte = 3 });
//     try compound_tags.append(nbt.Tag.init("list", .{ .List = list_tags }));
//
//     var int_array = [_]i32{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("int_array", .{ .IntArray = &int_array }));
//
//     var long_array = [_]i64{ 1, 2, 3, 4 };
//     try compound_tags.append(nbt.Tag.init("long_array", .{ .LongArray = &long_array }));
//
//     var nested_compound_tags = std.ArrayList(nbt.Tag).init(allocator);
//     defer nested_compound_tags.deinit();
//     try nested_compound_tags.append(nbt.Tag.init("nested_byte", .{ .Byte = 99 }));
//     try nested_compound_tags.append(nbt.Tag.init("nested_string", .{ .String = "Nested Hello!" }));
//     try compound_tags.append(nbt.Tag.init("nested_compound", .{ .Compound = nested_compound_tags }));
//
//     const root_tag = nbt.Tag.init("root", .{ .Compound = compound_tags });
//
//     nbt.Printer.print(root_tag, 0);
// }
