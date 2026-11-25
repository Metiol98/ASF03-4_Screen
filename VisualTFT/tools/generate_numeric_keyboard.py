from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
WIDTH, HEIGHT = 760, 520
UP_PATH = ROOT / "images" / "keyboard_numeric_up.png"
DOWN_PATH = ROOT / "images" / "keyboard_numeric_down.png"

KEYS = [
    ("1", "1", 0, 0, 0), ("2", "2", 0, 1, 0), ("3", "3", 0, 2, 0), ("+/-", "+-", 0, 3, 0), ("Del", "a", 0, 4, 3),
    ("4", "4", 1, 0, 0), ("5", "5", 1, 1, 0), ("6", "6", 1, 2, 0), (".", ".", 1, 3, 0), ("Esc", "a", 1, 4, 4),
    ("7", "7", 2, 0, 0), ("8", "8", 2, 1, 0), ("9", "9", 2, 2, 0), ("0", "0", 2, 3, 0), ("Enter", "a", 2, 4, 1),
]

X0, Y0, GAP_X, GAP_Y = 28, 150, 10, 12
KEY_W, KEY_H = 132, 100

def rounded_key(draw, box, fill, outline):
    draw.rounded_rectangle(box, radius=4, fill=fill, outline=outline, width=1)


def key_bounds(label, row, col):
    x = X0 + col * (KEY_W + GAP_X)
    y = Y0 + row * (KEY_H + GAP_Y)
    return x, y, KEY_W, KEY_H


def render_background(path, pressed=False):
    image = Image.new("RGB", (WIDTH, HEIGHT), "#191b22")
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((0, 0, WIDTH - 1, HEIGHT - 1), radius=10, fill="#191b22", outline="#4f5663", width=2)
    draw.rounded_rectangle((30, 27, 582, 125), radius=4, fill="#f1f2ef", outline="#858b91", width=2)
    close_fill = "#c8ccd2" if pressed else "#e2e5e9"
    draw.rounded_rectangle((690, 18, 742, 70), radius=3, fill=close_fill, outline="#858b91", width=2)
    draw.line((701, 28, 731, 60), fill="#30343a", width=4)
    draw.line((731, 28, 701, 60), fill="#30343a", width=4)

    regular_font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 52)
    action_font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 38)
    for label, _, row, col, _ in KEYS:
        x, y, width, height = key_bounds(label, row, col)
        fill = "#c7c6d5" if pressed else "#deddeb"
        outline = "#a09eac"
        rounded_key(draw, (x, y, x + width, y + height), fill, outline)
        font = regular_font if label in "0123456789" else action_font
        if label == "Enter":
            color = "#161a21"
            draw.line((x + 36, y + 34, x + 98, y + 34), fill=color, width=6)
            draw.line((x + 98, y + 34, x + 98, y + 65), fill=color, width=6)
            draw.line((x + 98, y + 65, x + 62, y + 65), fill=color, width=6)
            draw.polygon([(x + 62, y + 65), (x + 76, y + 54), (x + 76, y + 76)], fill=color)
            continue
        bounds = draw.textbbox((0, 0), label, font=font)
        text_x = x + (width - (bounds[2] - bounds[0])) / 2
        text_y = y + (height - (bounds[3] - bounds[1])) / 2 - bounds[1]
        draw.text((text_x, text_y), label, font=font, fill="#202a36")

    image.save(path, optimize=True)


def add_item(page, attrs):
    ET.SubElement(page, "item", attrs)


def make_small_keyboard():
    page = ET.Element("DrawPage", {
        "name": "Screen2", "bk_transparent": "0", "bk_color": "0;0;255", "bk_image": "",
        "size_option": "0", "width": str(WIDTH), "height": str(HEIGHT),
    })
    add_item(page, {
        "name": "Image1", "id": "1", "type": "image", "url": "images\\keyboard_numeric_up.png",
        "transparency": "0", "crop": "0", "xOffset": "0", "yOffset": "0",
        "width": str(WIDTH), "height": str(HEIGHT), "filter": "0", "clr_low": "0;0;0",
        "control_enable": "0", "clock": "0", "angle": "0", "rotate_x_offset": "0",
        "rotate_y_offset": "0", "precision": "0", "angle_limit": "0", "angle_max": "360",
        "notify": "0",
    })
    add_item(page, {
        "name": "Text_Display1", "id": "2", "type": "text_display", "text": "", "tipinfo": "",
        "font": "16", "encode": "1", "show_bkg_style": "0", "fore_color": "25;35;48",
        "bkg_color": "0;255;0", "bkg_image_path": "", "xOffset": "42", "yOffset": "52",
        "width": "536", "height": "48", "input_mode": "2", "variant": "0", "text_type": "0",
        "text_len_max": "32", "password": "0", "focus_rect": "0", "text_align": "0",
        "text_align_v": "1", "value_limit": "0", "value_precision": "0", "max_value": "50000",
        "min_value": "0", "keyboard_init": "0", "keyboard_position": "0", "keyboard_x": "0",
        "keyboard_y": "0", "art_digit": "0", "art_digit_icon": "", "half_width_dot": "0",
        "bind_variant": "", "show_condition": "0", "condition_variant": "", "condition_value": "0",
    })

    for index, (label, code, row, col, key_type) in enumerate(KEYS, start=3):
        x, y, width, height = key_bounds(label, row, col)
        add_item(page, {
            "name": f"Button{index - 2}", "id": str(index), "type": "button", "button_type": "2",
            "focus": "1", "notify_disable": "0", "key_code": code, "key_type": str(key_type),
            "init_state": "0", "button_style": "0", "longpress_delay": "0", "url_down": "images\\keyboard_numeric_down.png",
            "url_up": "", "popup_menu_id": "0", "input_text_id": "0", "switch": "",
            "switch_effect": "0", "switch_area": "0", "switch_area_left": "0", "switch_area_right": "0",
            "switch_area_top": "0", "switch_area_bottom": "0", "action": "", "xOffset": str(x),
            "yOffset": str(y), "width": str(width), "height": str(height), "cut_up": "0",
            "cut_up_offset_x": "0", "cut_up_offset_y": "0", "cut_down": "1",
            "cut_down_offset_x": str(x), "cut_down_offset_y": str(y), "custom_data_up": "",
            "custom_data_down": "", "external_data_up": "", "external_data_down": "",
            "external_data_delay": "100", "child_screen": "0", "need_login": "0",
            "login_password": "888888", "show_text_state": "0", "font": "7",
            "font_color_up": "255;255;255", "font_color_down": "255;255;255",
            "text_state_up": "", "text_state_down": "", "bind_variant": "",
            "show_condition": "0", "condition_variant": "", "condition_value": "0",
        })

    add_item(page, {
        "name": "ButtonClose", "id": str(len(KEYS) + 3), "type": "button", "button_type": "2",
        "focus": "1", "notify_disable": "0", "key_code": "a", "key_type": "4", "init_state": "0",
        "button_style": "0", "longpress_delay": "0", "url_down": "images\\keyboard_numeric_down.png",
        "url_up": "", "popup_menu_id": "0", "input_text_id": "0", "switch": "", "switch_effect": "0",
        "switch_area": "0", "switch_area_left": "0", "switch_area_right": "0", "switch_area_top": "0",
        "switch_area_bottom": "0", "action": "", "xOffset": "678", "yOffset": "6", "width": "76",
        "height": "76", "cut_up": "0", "cut_up_offset_x": "0", "cut_up_offset_y": "0", "cut_down": "1",
        "cut_down_offset_x": "678", "cut_down_offset_y": "6", "custom_data_up": "", "custom_data_down": "",
        "external_data_up": "", "external_data_down": "", "external_data_delay": "100", "child_screen": "0",
        "need_login": "0", "login_password": "888888", "show_text_state": "0", "font": "7",
        "font_color_up": "255;255;255", "font_color_down": "255;255;255", "text_state_up": "",
        "text_state_down": "", "bind_variant": "", "show_condition": "0", "condition_variant": "",
        "condition_value": "0",
    })
    return ET.ElementTree(page)


def main():
    UP_PATH.parent.mkdir(parents=True, exist_ok=True)
    render_background(UP_PATH)
    render_background(DOWN_PATH, pressed=True)
    tree = make_small_keyboard()
    ET.indent(tree, space="  ")
    tree.write(ROOT / "keyboard0.xml", encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    main()
