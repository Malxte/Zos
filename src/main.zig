const vga_buffer: *volatile [25 * 80 * 2]u8 = @ptrFromInt(0xb8000);
const keyboard = @import("keyboard.zig");

var cursor_x: u8 = 0;
var cursor_y: u8 = 0;
const vga_width = 80;
const vga_height = 25;

fn print_char(char: u8, color: u8) void {
    if (char == '\n') {
        cursor_x = 0;
        cursor_y += 1;
    } else if (char == 0x08) { // Backspace
        if (cursor_x > 0) {
            cursor_x -= 1;
            const offset = (cursor_y * vga_width + cursor_x) * 2;
            vga_buffer[offset] = ' ';
            vga_buffer[offset + 1] = color;
        }
    } else {
        const offset = (cursor_y * vga_width + cursor_x) * 2;
        vga_buffer[offset] = char;
        vga_buffer[offset + 1] = color;
        cursor_x += 1;
    }

    if (cursor_x >= vga_width) {
        cursor_x = 0;
        cursor_y += 1;
    }

    if (cursor_y >= vga_height) {
        // Simple scroll
        for (1..vga_height) |y| {
            for (0..vga_width) |x| {
                const from = ((y * vga_width) + x) * 2;
                const to = (((y - 1) * vga_width) + x) * 2;
                vga_buffer[to] = vga_buffer[from];
                vga_buffer[to + 1] = vga_buffer[from + 1];
            }
        }
        // Clear last line
        for (0..vga_width) |x| {
            const offset = ((vga_height - 1) * vga_width + x) * 2;
            vga_buffer[offset] = ' ';
            vga_buffer[offset + 1] = color;
        }
        cursor_y = vga_height - 1;
        cursor_x = 0;
    }
}

fn print_string(s: []const u8, color: u8) void {
    for (s) |char| {
        print_char(char, color);
    }
}

pub export fn kmain() void {
    // Clear screen
    for (0..(vga_width * vga_height)) |i| {
        vga_buffer[i * 2] = ' ';
        vga_buffer[i * 2 + 1] = 0x0f;
    }

    print_string("Welcome to my OS! Keyboard input is enabled.\n", 0x0f);

    while (true) {
        if (keyboard.getchar()) |char| {
            print_char(char, 0x0f);
        }
    }
}
