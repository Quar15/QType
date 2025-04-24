const std = @import("std");
const rand = std.crypto.random;
const rl = @import("raylib");
const key = @import("key.zig");
const game_key = @import("game_key.zig");
const utils = @import("utils.zig");


pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    rl.initWindow(1920, 1080, "QType");
    defer rl.closeWindow(); // Close window and OpenGL context
    var screen_size = utils.getScreenSize();
    var screen_width:f32 = screen_size.x;
    var screen_height:f32 = screen_size.y;

    const FONT_SIZE:u8 = 32;
    const embedded_font_data = @embedFile("assets/roboto.ttf");
    const FONT = rl.loadFontFromMemory(".ttf", embedded_font_data, FONT_SIZE, null) catch @panic("@ERROR: Failed to load font");
    defer FONT.unload();
    const KEY_SIZE:f32 = 64.0;
    const SPACING:f32 = 5.0;
    var start_x:f32 = (screen_width - 10 * (SPACING + KEY_SIZE)) / 2;
    var start_y:f32 = FONT_SIZE + SPACING + 150 + (screen_height - 4 * (SPACING + KEY_SIZE)) / 2;

    const CHARACTER_LIMIT:u32 = 32;

    // Color RGBA
    const BACKGROUND_COLOR: rl.Color = rl.getColor(0xf4f0f0ff);
    // const SECONDARY_COLOR: rl.Color = rl.getColor(0x141320ff);

    const PRESSED_KEY_COLOR: rl.Color = rl.getColor(0x282640ff);

    const LEFT_INDEX_KEY_COLOR: rl.Color = rl.getColor(0x83a698ff);
    const RIGHT_INDEX_KEY_COLOR: rl.Color = rl.getColor(0xd3869bff);
    const MIDDLE_KEY_COLOR: rl.Color = rl.getColor(0xfabd2fff);
    const RING_KEY_COLOR: rl.Color = rl.getColor(0xb8bb26ff);
    const PINKY_KEY_COLOR: rl.Color = rl.getColor(0x8ec07cff);
    const THUMB_KEY_COLOR: rl.Color = rl.getColor(0xd66354ff);


    var keys: [27]key.Key = .{
        key.Key.init('Q', KEY_SIZE, FONT, FONT_SIZE, PINKY_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('W', KEY_SIZE, FONT, FONT_SIZE, RING_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('E', KEY_SIZE, FONT, FONT_SIZE, MIDDLE_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('R', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('T', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('Y', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('U', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('I', KEY_SIZE, FONT, FONT_SIZE, MIDDLE_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('O', KEY_SIZE, FONT, FONT_SIZE, RING_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('P', KEY_SIZE, FONT, FONT_SIZE, PINKY_KEY_COLOR, PRESSED_KEY_COLOR),

        // Row 2: A - L (offset by half key width)
        key.Key.init('A', KEY_SIZE, FONT, FONT_SIZE, PINKY_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('S', KEY_SIZE, FONT, FONT_SIZE, RING_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('D', KEY_SIZE, FONT, FONT_SIZE, MIDDLE_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('F', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('G', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('H', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('J', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('K', KEY_SIZE, FONT, FONT_SIZE, MIDDLE_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('L', KEY_SIZE, FONT, FONT_SIZE, RING_KEY_COLOR, PRESSED_KEY_COLOR),

        // Row 3: Z - M (offset a bit more)
        key.Key.init('Z', KEY_SIZE, FONT, FONT_SIZE, PINKY_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('X', KEY_SIZE, FONT, FONT_SIZE, RING_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('C', KEY_SIZE, FONT, FONT_SIZE, MIDDLE_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('V', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('B', KEY_SIZE, FONT, FONT_SIZE, LEFT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('N', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),
        key.Key.init('M', KEY_SIZE, FONT, FONT_SIZE, RIGHT_INDEX_KEY_COLOR, PRESSED_KEY_COLOR),

        key.Key.init(' ', KEY_SIZE, FONT, FONT_SIZE, THUMB_KEY_COLOR, PRESSED_KEY_COLOR),
    };

    for (0..27) |i| {
        std.debug.print("@DEBUG: Key[{d}] initialied '{c}'\n", .{i, keys[i].character});
    }

    updateKeyboardPosition(&keys, start_x, start_y, KEY_SIZE, SPACING);

    var game_keys: [CHARACTER_LIMIT]game_key.GameKey = undefined;
    for (0..CHARACTER_LIMIT) |i| {
        game_keys[i] = game_key.GameKey.init(0, FONT, FONT_SIZE, PRESSED_KEY_COLOR, PINKY_KEY_COLOR, RIGHT_INDEX_KEY_COLOR);
    }

    rl.setWindowSize(@intFromFloat(screen_width), @intFromFloat(screen_height));
    if (!rl.isWindowFullscreen()) {
        rl.toggleFullscreen();
    }

    const new_screen_size = utils.getScreenSize();
    if (screen_size.x != new_screen_size.x) {
        screen_size = new_screen_size;
        screen_width = new_screen_size.x;
        screen_height = new_screen_size.y;
        start_x = (screen_width - 10 * (SPACING + KEY_SIZE)) / 2;
        start_y = FONT_SIZE + SPACING + 50 + (screen_height - 4 * (SPACING + KEY_SIZE)) / 2;
    }

    rl.setTargetFPS(60); // Set app to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const ALLOCATOR = std.heap.page_allocator;
    const WORDS = try utils.loadWordList(ALLOCATOR, "./assets/words-en.txt");
    defer ALLOCATOR.free(WORDS);

    var curr_game_key_index: u8 = 0;
    var row_completed: bool = true;
    var ok_input: u64 = 0;
    var all_input: u64 = 0;
    var curr_words_width: f32 = 0;
    var words_count: i64 = 0;
    var timer = utils.Timer.init();
    var timer_split_started: bool = false;
    var timer_all_time: f64 = 0;
    var input_line_x: f32 = 0;
    // Main app loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(BACKGROUND_COLOR);

        for (0..27) |i| {
            keys[i].update();
            keys[i].draw();
        }

        if (row_completed) {
            timer_split_started = false;
            timer_all_time += timer.elapsedS();
            // Count accuracy
            for (0..CHARACTER_LIMIT) |i| {
                if (game_keys[i].character == 0) {
                    continue;
                }
                if (game_keys[i].character == ' ') {
                    words_count += 1;
                }
                if (game_keys[i].first_try) {
                    ok_input += 1;
                }
                all_input += 1;
            }
            std.debug.print("@DEBUG: Started generation\n", .{});
            row_completed = false;
            curr_words_width = 0;
            var i: u8 = 0;
            while (i < CHARACTER_LIMIT) {
                const rng:usize = rand.intRangeLessThan(usize, 0, WORDS.len);
                var c:u8 = undefined;
                // Always allow for space at the end
                if (WORDS[rng].len + i + 1 > CHARACTER_LIMIT) {
                    c = 0;
                    game_keys[i].updateChar(c); 
                    curr_words_width += game_keys[i].getCharacterWidth() + SPACING;
                    i += 1;
                    continue;
                }
                const random_word = WORDS[rng];
                for (random_word) |char| {
                    game_keys[i].updateChar(char);
                    curr_words_width += game_keys[i].getCharacterWidth() + SPACING;
                    i += 1;
                }
                if (i < CHARACTER_LIMIT) {
                    c = ' ';
                    game_keys[i].updateChar(c); 
                    curr_words_width += game_keys[i].getCharacterWidth() + SPACING;
                    i += 1;
                }
            }
            std.debug.print("@DEBUG: Filled with words\n", .{});
            std.debug.print("@DEBUG: Calculating width\n", .{});
            var curr_x: f32 = (screen_width - curr_words_width) / 2;
            for (0..game_keys.len) |index| {
                game_keys[index].updatePos(rl.Vector2.init(curr_x, start_y - 100));
                curr_x += game_keys[index].getCharacterWidth() + SPACING;
            }
            std.debug.print("@DEBUG: Finished\n", .{});
        }
        for (0..CHARACTER_LIMIT) |i| {
            game_keys[i].draw();
            if (i == curr_game_key_index) {
                input_line_x = game_keys[i].position.x;
            }
        }

        if (game_keys[curr_game_key_index].checkInput()) {
            if (timer_split_started == false) {
                timer.startTimer();
                timer_split_started = true;
            }
            curr_game_key_index += 1;
            if (curr_game_key_index >= game_keys.len) {
                curr_game_key_index = 0;
                row_completed = true;
            }
        }
        rl.drawRectangle(@intFromFloat(input_line_x - 3.0), @intFromFloat(start_y - 100), 2, FONT_SIZE, PRESSED_KEY_COLOR);
        drawStats(ok_input, all_input, words_count, timer_all_time, FONT, FONT_SIZE, rl.Vector2.init(start_x, start_y - 200), PRESSED_KEY_COLOR);
    }
}

fn updateKeyboardPosition(keys:*[27]key.Key, start_x: f32, start_y: f32, key_size: f32, spacing: f32) void
{
    for (0..10) |i| {
        const float_i: f32 = @floatFromInt(i);
        keys[i].updatePos(start_x + float_i * (key_size + spacing), start_y);
    }
    for (10..19) |i| {
        const float_i: f32 = @floatFromInt(i);
        keys[i].updatePos(start_x + (float_i - 9 - 0.5) * (key_size + spacing), start_y + spacing + key_size);
    }
    for (19..26) |i| {
        const float_i: f32 = @floatFromInt(i);
        keys[i].updatePos(start_x + (float_i - 18) * (key_size + spacing), start_y + 2 * (spacing + key_size));
    }
    keys[26].updatePos(start_x + 2.5 * (key_size + spacing), start_y + 3 * (spacing + key_size));
}

fn drawStats(ok_keys: u64, all_keys: u64, words_count: i64, timer_time_s: f64, font: rl.Font, p_font_size: f32, position: rl.Vector2, color: rl.Color) void
{
    if (all_keys <= 0) {
        return;
    }
    const percent = @as(f64, @floatFromInt(ok_keys)) / @as(f64, @floatFromInt(all_keys)) * 100.0;
    const allocator = std.heap.page_allocator;
    var wpm: f64 = 0;
    if (timer_time_s > 0) {
        wpm = @floatFromInt(words_count);
        wpm = 60 * wpm / timer_time_s;
    }
    const buffer:[:0]u8 = std.fmt.allocPrintZ(allocator, "{d:.2}% [{d}/{d}] | {d} words | {d:.2}wpm | {d:.2}s", .{percent, ok_keys, all_keys, words_count, wpm, timer_time_s}) catch unreachable;
    defer allocator.free(buffer);
    const font_size: f32 = p_font_size;
    rl.drawTextEx(font, buffer, position, font_size * 2 / 3, 1, color);
}
