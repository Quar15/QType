const rl = @import("raylib");
const std = @import("std");

pub fn getKeyboardKeyFromChar(c: u8) rl.KeyboardKey {
    return switch (std.ascii.toUpper(c)) {
        'A' => rl.KeyboardKey.a,
        'B' => rl.KeyboardKey.b,
        'C' => rl.KeyboardKey.c,
        'D' => rl.KeyboardKey.d,
        'E' => rl.KeyboardKey.e,
        'F' => rl.KeyboardKey.f,
        'G' => rl.KeyboardKey.g,
        'H' => rl.KeyboardKey.h,
        'I' => rl.KeyboardKey.i,
        'J' => rl.KeyboardKey.j,
        'K' => rl.KeyboardKey.k,
        'L' => rl.KeyboardKey.l,
        'M' => rl.KeyboardKey.m,
        'N' => rl.KeyboardKey.n,
        'O' => rl.KeyboardKey.o,
        'P' => rl.KeyboardKey.p,
        'Q' => rl.KeyboardKey.q,
        'R' => rl.KeyboardKey.r,
        'S' => rl.KeyboardKey.s,
        'T' => rl.KeyboardKey.t,
        'U' => rl.KeyboardKey.u,
        'V' => rl.KeyboardKey.v,
        'W' => rl.KeyboardKey.w,
        'X' => rl.KeyboardKey.x,
        'Y' => rl.KeyboardKey.y,
        'Z' => rl.KeyboardKey.z,

        '0' => rl.KeyboardKey.zero,
        '1' => rl.KeyboardKey.one,
        '2' => rl.KeyboardKey.two,
        '3' => rl.KeyboardKey.three,
        '4' => rl.KeyboardKey.four,
        '5' => rl.KeyboardKey.five,
        '6' => rl.KeyboardKey.six,
        '7' => rl.KeyboardKey.seven,
        '8' => rl.KeyboardKey.eight,
        '9' => rl.KeyboardKey.nine,

        ' ' => rl.KeyboardKey.space,

        else => rl.KeyboardKey.null,
    };
}

pub fn getCharacterWidth(char: u8, font: rl.Font, font_size: f32, spacing: f32) rl.Vector2 {
        const character_buffer = [2]u8 {char, 0};
        return rl.measureTextEx(font, @ptrCast(&character_buffer), font_size, spacing);
}

pub fn loadWordList(allocator: std.mem.Allocator, filepath: []const u8) ![]const []const u8 {
    const file = std.fs.cwd().openFile(filepath, .{}) catch unreachable;
    defer file.close();

    const stat = try file.stat();
    const file_size = stat.size;

    // Read entire file into memory
    var file_buffer:[]u8 = allocator.alloc(u8, file_size) catch unreachable;
    defer allocator.free(file_buffer);

    _ = try file.readAll(file_buffer);

    var lines:std.ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();
    const BUFFER_LENGTH:usize = file_buffer.len;
    var curr_index:usize = 0;
    var line_count: u32 = 0;
    for (0..BUFFER_LENGTH) |i|
    {
        if (file_buffer[i] == '\n')
        {
            const line = try allocator.dupe(u8, file_buffer[curr_index..i]);
            try lines.append(line);
            curr_index = i + 1;
            line_count += 1;
        }
    }
    if (curr_index < BUFFER_LENGTH) {
        const line = try allocator.dupe(u8, file_buffer[curr_index..]);
        try lines.append(line);
    }

    std.debug.print("@INFO: Loaded file with {} words\n", .{line_count});
    var words = try allocator.alloc([]const u8, line_count);
    for (0..line_count) |i| {
        words[i] = lines.items[i];
    }

    return words;
}

pub fn getScreenSize() rl.Vector2
{
    const curr_monitor = rl.getCurrentMonitor();

    const screen_width:f32 = @floatFromInt(rl.getMonitorWidth(curr_monitor));
    const screen_height:f32 = @floatFromInt(rl.getMonitorHeight(curr_monitor));
    std.debug.print("@INFO: Detected monitor size {d}x{d}\n", .{screen_width, screen_height});
    return rl.Vector2.init(
        screen_width,
        screen_height
    );
}

pub const Timer = struct {
    start: i64,

    pub fn init() Timer {
        return Timer{ .start = std.time.milliTimestamp() };
    }

    pub fn startTimer(self: *Timer) void {
       self.start = std.time.milliTimestamp();
    }

    pub fn elapsedMs(self: *Timer) i64 {
        return std.time.milliTimestamp() - self.start;
    }

    pub fn elapsedS(self: *Timer) f64 {
        const ms = self.elapsedMs();
        var s: f64 = @floatFromInt(ms);
        s = s / 1000.0;
        return s;
    }
};
