const rl = @import("raylib");
const utils = @import("utils.zig");

pub const Key = struct {
    character: u8,
    position: rl.Vector2,
    size: rl.Vector2,
    font: rl.Font,
    font_size: u8,
    is_clicked: bool,
    normal_color: rl.Color,
    clicked_color: rl.Color,

    pub fn init(character: u8, size: f32, font: rl.Font, font_size: u8, normal_color: rl.Color, clicked_color: rl.Color) Key {
        var key_size = rl.Vector2.init(size, size);
        if (character == ' ') {
            key_size = rl.Vector2.init(6.5 * size, size);
        }
        return Key{
            .character = character,
            .position = rl.Vector2.init(0, 0),
            .size = key_size,
            .font = font,
            .font_size = font_size,
            .is_clicked = false,
            .normal_color = normal_color,
            .clicked_color = clicked_color,
        };
    }

    pub fn update(self: *Key) void {
        if (rl.isKeyDown(utils.getKeyboardKeyFromChar(self.character))){
            self.is_clicked = true;
        } else {
            self.is_clicked = false;
        }
    }

    pub fn updatePos(self: *Key, x: f32, y:f32) void {
        self.position = rl.Vector2.init(x, y);
    }

    pub fn draw(self: *Key) void {
        var bg_color: rl.Color = self.normal_color;
        var text_color: rl.Color = self.clicked_color;
        if (self.is_clicked) {
            bg_color = self.clicked_color;
            text_color = self.normal_color;
        }
        rl.drawRectangleV(
            self.position,
            self.size,
            bg_color,
        );
        const character_buffer = [2]u8 {self.character, 0};
        const font_size: f32 = @floatFromInt(self.font_size);
        const font_sizes: rl.Vector2 = rl.measureTextEx(self.font, @ptrCast(&character_buffer), font_size, 2);
        const text_pos = rl.Vector2.init(
            self.position.x + self.size.x / 2 - font_sizes.x / 2,
            self.position.y + self.size.y / 2 - font_sizes.y / 2,
        );
        rl.drawTextEx(
            self.font,
            @ptrCast(&character_buffer),
            rl.Vector2.init(text_pos.x, text_pos.y),
            font_size,
            2,
            text_color
        );
    }
};
