const std = @import("std");

// PS/2 controller ports
const KEYBOARD_DATA_PORT: u16 = 0x60;
const KEYBOARD_STATUS_PORT: u16 = 0x64;

// Scancode set 1 to ASCII for German layout
const scancode_to_ascii_de = [_]u8{
    // 0x00
    0x00, 0x1B, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'ß', '´', 0x08, 0x09, // \t
    // 0x10
    'q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o', 'p', 'ü', '+', 0x0A, 0x00, 'a', 's', // \n
    // 0x20
    'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ö', 'ä', '^', 0x00, '#', 'y', 'x', 'c', 'v',
    // 0x30
    'b', 'n', 'm', ',', '.', '-', 0x00, '*', 0x00, ' ', 0x00, 0x00, 0x00, 0x00, 0x00,
    // 0x40
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, '7', '8', '9', '-', '4', '5', '6', '+',
    // 0x50
    '1', '2', '3', '0', '.', 0x00, '<', 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

fn inb(port: u16) u8 {
    var value: u8 = undefined;
    asm volatile (
        "in %[port], %[value]"
        : [value] "={al}" (value)
        : [port] "{dx}" (port)
    );
    return value;
}


// This is a very basic implementation. A real driver would need to handle shift, ctrl, alt, key releases, etc.

fn read_scancode() u8 {
    while (inb(KEYBOARD_STATUS_PORT) & 1 == 0) {}
    return inb(KEYBOARD_DATA_PORT);
}

pub fn getchar() ?u8 {
    const scancode = read_scancode();

    // For now, we only handle key presses, not releases (scancode > 0x80)
    if (scancode > 0x80) {
        return null;
    }

    if (scancode >= scancode_to_ascii_de.len) {
        return null;
    }

    const char = scancode_to_ascii_de[scancode];
    if (char == 0x00) {
        return null;
    }

    return char;
}
