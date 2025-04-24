const std = @import("std");
const rl = @import("raylib");
const utils = @import("utils.zig");

pub const GameKey = struct {
    character: u8,
    position: rl.Vector2,
    font: rl.Font,
    font_size: u8,
    normal_color: rl.Color,
    ok_color: rl.Color,
    wrong_color: rl.Color,
    first_try: bool,
    completed: bool,

    pub fn init(
        character: u8,
        font: rl.Font,
        font_size: u8,
        normal_color: rl.Color,
        ok_color: rl.Color,
        wrong_color: rl.Color
    ) GameKey {
        return GameKey{
            .character = character,
            .position = rl.Vector2.init(0, 0),
            .font = font,
            .font_size = font_size,
            .normal_color = normal_color,
            .ok_color = ok_color,
            .wrong_color = wrong_color,
            .first_try = true,
            .completed = false,
        };
    }

    pub fn checkInput(self: *GameKey) bool {
        if (self.character == 0) {
            // @NOTE: This can create bugs with wpm if not considered
            return true;
        }
        if (rl.getKeyPressed() == rl.KeyboardKey.null) {
            return false;
        }
        if (!rl.isKeyPressed(utils.getKeyboardKeyFromChar(self.character))){
            self.first_try = false;
            return false;
        }
        self.completed = true;
        return true;
    }

    pub fn updateChar(self: *GameKey, new_char: u8) void {
        self.character = new_char;
        self.completed = false;
        self.first_try = true;
    }

    pub fn updatePos(self: *GameKey, new_pos: rl.Vector2) void {
        self.position = new_pos;
    }

    pub fn getCharacterWidth(self: *GameKey) f32 {
        const font_size: f32 = @floatFromInt(self.font_size);
        return utils.getCharacterWidth(self.character, self.font, font_size, 1).x;
    }

    pub fn draw(self: *GameKey) void {
        var text_color: rl.Color = self.normal_color;
        if (self.completed) {
            if (self.first_try) {
                text_color = self.ok_color;
            } else {
                text_color = self.wrong_color;
            }
        }

        if (self.character == ' ') {
            const font_size: f32 = @floatFromInt(self.font_size);
            rl.drawRectangle(
                @intFromFloat(self.position.x - 2 + self.getCharacterWidth() / 2.0),
                @intFromFloat(self.position.y - 2 + (font_size) / 2.0),
                4,
                4,
                text_color,
            );
        } else {
            const character_buffer = [2]u8 {self.character, 0};
            const font_size: f32 = @floatFromInt(self.font_size);
            rl.drawTextEx(
                self.font,
                @ptrCast(&character_buffer),
                rl.Vector2.init(self.position.x, self.position.y),
                font_size,
                2,
                text_color
            );
        }
    }
};
