from typing import Literal
from math import floor
import curses
import time

Opciones_icon = Literal[
    "ACS_BBSS",
    "ACS_BLOCK",
    "ACS_BOARD",
    "ACS_BSBS",
    "ACS_BSSB",
    "ACS_BSSS",
    "ACS_BTEE",
    "ACS_BULLET",
    "ACS_CKBOARD",
    "ACS_DARROW",
    "ACS_DEGREE",
    "ACS_DIAMOND",
    "ACS_GEQUAL",
    "ACS_HLINE",
    "ACS_LANTERN",
    "ACS_LARROW",
    "ACS_LEQUAL",
    "ACS_LLCORNER",
    "ACS_LRCORNER",
    "ACS_LTEE",
    "ACS_NEQUAL",
    "ACS_PI",
    "ACS_PLMINUS",
    "ACS_PLUS",
    "ACS_RARROW",
    "ACS_RTEE",
    "ACS_S1",
    "ACS_S3",
    "ACS_S7",
    "ACS_S9",
    "ACS_SBBS",
    "ACS_SBSB",
    "ACS_SBSS",
    "ACS_SSBB",
    "ACS_SSBS",
    "ACS_SSSB",
    "ACS_SSSS",
    "ACS_STERLING",
    "ACS_TTEE",
    "ACS_UARROW",
    "ACS_ULCORNER",
    "ACS_URCORNER",
    "ACS_VLINE",
]


def rect(page, x, y, width, height, color_pair):
    for i in range(height):
        for j in range(width):
            page.addch(y + i, x + j, " ", color_pair)


def draw(page, x, y, text, color=1):
    page.addstr(y, x, text, curses.color_pair(color))


def icon_draw(page, x, y, icon: Opciones_icon):
    page.addch(y, x, icon)


class Widget:
    disabled = False
    visible = True
    focus = False
    static = False

    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

    def update(self, key, gui):
        pass

    def start(self, gui):
        pass

    def on_click(self, gui):
        pass

    def on_focus(self, page):
        pass

    def draw(self, page):
        pass


class Static_widget:
    visible = True
    static = True

    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

    def update(self, key, gui):
        pass

    def start(self, gui):
        pass

    def draw(self, page):
        pass


class Icon(Static_widget):

    def __init__(self, x, y, icon: Opciones_icon) -> None:
        super().__init__(x, y)
        self.icon = icon

    def draw(self, page):
        icon_draw(page, self.x, self.y, self.icon)


class Text(Static_widget):
    def __init__(self, x, y, text="") -> None:
        super().__init__(x, y)
        self.text = text

    def draw(self, page):
        draw(page, self.x, self.y, self.text, 1)


class ProgressBar(Static_widget):
    def __init__(self, x, y, width, max_value):
        self.x = x
        self.y = y
        self.width = width
        self.max_value = max_value
        self.value = 0

    def draw(self, page):
        bar = "=" * int(self.value / self.max_value * self.width)
        draw(
            page,
            self.x,
            self.y,
            f"[{bar:<{self.width}}] {self.value}/{self.max_value}",
        )

    def set_value(self, value):
        self.value = max(0, min(value, self.max_value))


class Spinner(Static_widget):
    active = False
    current_frame = 0
    page = False
    parar = False

    def __init__(self, x, y, speed=0.1, frames=["-", "\\", "|", "/"]):
        self.x = x
        self.y = y
        self.frames = frames
        self.speed = speed

    def start(self, gui):
        self.page = gui.page
        self.active = True

    def mainloop(self):
        while True:
            if self.parar:
                break
            if self.active:
                self.draw(self.page)
                self.page.refresh()
                self.current_frame = (self.current_frame + 1) % len(self.frames)
            time.sleep(self.speed)

    def stop(self):
        self.active = False
        self.parar = True

    def draw(self, page):
        draw(page, self.x, self.y, self.frames[self.current_frame])
        page.refresh()


class Rectangle(Static_widget):
    def __init__(self, x, y, width, height):
        super().__init__(x, y)
        self.width = width
        self.height = height
        self.callback = "+" + ("-" * (width - 2)) + "+\n"

    def draw(self, page):
        for i in range(self.height + 2):
            page.addch(self.y - 1 + i, self.x - 1, curses.ACS_VLINE)
            page.addch(self.y - 1 + i, self.x + self.width, curses.ACS_VLINE)
        for i in range(self.width + 2):
            page.addch(self.y - 1, self.x - 1 + i, curses.ACS_HLINE)
            page.addch(self.y + self.height, self.x - 1 + i, curses.ACS_HLINE)
        page.addch(self.y - 1, self.x - 1, curses.ACS_ULCORNER)
        page.addch(self.y - 1, self.x + self.width, curses.ACS_URCORNER)
        page.addch(self.y + self.height, self.x - 1, curses.ACS_LLCORNER)
        page.addch(self.y + self.height, self.x + self.width, curses.ACS_LRCORNER)


class Canvas(Static_widget):
    def __init__(self, x, y, width, height):
        super().__init__(x, y)
        self.width = width
        self.height = height
        self.buffer = [[" " for _ in range(width)] for _ in range(height)]

    def draw(self, page):
        for i in range(self.height):
            page.addstr(self.y + i, self.x, "".join(self.buffer[i]))

    def clear(self):
        self.buffer = [[" " for _ in range(self.width)] for _ in range(self.height)]

    def set_pixel(self, x, y, char):
        if 0 <= x < self.width and 0 <= y < self.height:
            self.buffer[y][x] = char

    def draw_line(self, x1, y1, x2, y2, char):
        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        sx = 1 if x1 < x2 else -1
        sy = 1 if y1 < y2 else -1
        err = dx - dy

        while True:
            self.set_pixel(x1, y1, char)
            if x1 == x2 and y1 == y2:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x1 += sx
            if e2 < dx:
                err += dx
                y1 += sy

    def draw_rectangle(self, x, y, width, height, char):
        for i in range(height):
            for j in range(width):
                self.set_pixel(x + j, y + i, char)

    def draw_circle(self, xc, yc, r, char):
        x = r
        y = 0
        err = 0

        while x >= y:
            self.set_pixel(xc + x, yc + y, char)
            self.set_pixel(xc + y, yc + x, char)
            self.set_pixel(xc - x, yc + y, char)
            self.set_pixel(xc - y, yc + x, char)
            self.set_pixel(xc - x, yc - y, char)
            self.set_pixel(xc - y, yc - x, char)
            self.set_pixel(xc + x, yc - y, char)
            self.set_pixel(xc + y, yc - x, char)

            if err <= 0:
                y += 1
                err += 2 * y + 1
            if err > 0:
                x -= 1
                err -= 2 * x + 1


class Boton(Widget):
    def __init__(self, x, y, text, on_click=False) -> None:
        super().__init__(x, y)
        self.text = text
        if on_click:
            self.on_click = on_click

    def on_focus(self, page):
        draw(page, self.x, self.y, "[" + self.text + "]", 3)

    def draw(self, page):
        draw(page, self.x, self.y, "[" + self.text + "]", 4)


class Menu(Widget):
    id = 0
    activo = False

    def __init__(self, x, y, opciones=["Selecionar"]) -> None:
        super().__init__(x, y)
        self.opciones = opciones
        self.width = max(opciones, key=len)
        self.completas = [s.ljust(len(self.width)) for s in opciones]

    def update_menu(self):
        self.width = max(self.opciones, key=len)
        self.completas = [s.ljust(len(self.width)) for s in self.opciones]

    def on_click(self, gui):
        self.activo = not gui.submenu
        gui.submenu = not gui.submenu

    def update(self, key, gui):
        if self.activo:
            if key == curses.KEY_UP:
                self.id = max(self.id - 1, 0)
            elif key == curses.KEY_DOWN:
                self.id = min(self.id + 1, len(self.opciones) - 1)

    def on_focus(self, page):
        if self.activo:
            for i, v in enumerate(self.completas):
                draw(page, self.x, self.y + i, "|" + v, 4)
            draw(page, self.x, self.y + self.id, "|" + self.completas[self.id], 2)
        else:
            draw(page, self.x, self.y, "|" + self.completas[self.id] + "|", 3)

    def draw(self, page):
        draw(page, self.x, self.y, "|" + self.completas[self.id] + "|")


class Input_text(Widget):
    text = ""
    activo = False

    def __init__(self, x, y, width) -> None:
        super().__init__(x, y)
        self.width = width - 1

    def on_click(self, gui):
        self.activo = not gui.submenu
        gui.submenu = not gui.submenu

    def update(self, key, gui):
        if self.activo:
            if key == 8 or key == 127:
                self.text = self.text[:-1]
            else:
                char = chr(key) if key < 256 else ""
                if char.isprintable():
                    self.text += char

    def on_focus(self, page):
        if self.activo:
            if self.text == "":
                draw(page, self.x, self.y, ">" + ("_" * self.width), 2)
            else:
                draw(page, self.x, self.y, self.text[-(self.width + 2) :], 2)
        else:
            if self.text == "":
                draw(page, self.x, self.y, ">" + ("_" * self.width), 3)
            else:
                draw(page, self.x, self.y, ">" + self.text[: self.width], 3)

    def draw(self, page):
        draw(page, self.x, self.y, ">" + self.text[-self.width :])
        if self.text == "":
            draw(page, self.x, self.y, ">" + ("_" * self.width))


class Slider(Widget):
    activo = False

    def __init__(self, x, y, width, min_value=0, max_value=100, initial_value=1):
        self.x = x
        self.y = y
        self.width = width
        self.min_value = min_value
        self.max_value = max_value
        self.value = initial_value

    def on_click(self, gui):
        self.activo = not gui.submenu
        gui.submenu = not gui.submenu

    def update(self, key, gui):
        if self.activo:
            if key == curses.KEY_RIGHT:
                self.value = min(self.max_value, self.value + 1)
            elif key == curses.KEY_LEFT:
                self.value = max(self.min_value, self.value - 1)

    def on_focus(self, page):
        bar = "=" * int(
            (self.value - self.min_value)
            / (self.max_value - self.min_value)
            * self.width
        )
        if self.activo:
            draw(page, self.x, self.y, f"[{bar:<{self.width}}] {self.value}", 2)
        else:
            draw(page, self.x, self.y, f"[{bar:<{self.width}}] {self.value}", 3)

    def draw(self, page):
        bar = "=" * int(
            (self.value - self.min_value)
            / (self.max_value - self.min_value)
            * self.width
        )
        draw(page, self.x, self.y, f"[{bar:<{self.width}}] {self.value}", 1)


class Checkbox(Widget):
    activo = False

    def __init__(self, x, y, text="") -> None:
        super().__init__(x, y)
        self.text = text

    def on_click(self, gui):
        self.activo = not self.activo

    def on_focus(self, page):
        if self.activo:
            page.addstr(self.y, self.x, "[+]" + self.text, curses.color_pair(3))
        else:
            page.addstr(self.y, self.x, "[ ]" + self.text, curses.color_pair(3))

    def draw(self, page):
        if self.activo:
            page.addstr(self.y, self.x, "[+]" + self.text, curses.color_pair(4))
        else:
            page.addstr(self.y, self.x, "[ ]" + self.text, curses.color_pair(1))


class Toggle(Widget):
    id = 0
    activo = False

    def __init__(self, x, y, opciones=["Selecionar"]) -> None:
        super().__init__(x, y)
        self.opciones = opciones
        self.width = max(opciones, key=len)
        self.completas = [s.center(len(self.width)) for s in opciones]

    def update_menu(self):
        self.width = max(self.opciones, key=len)
        self.completas = [s.center(len(self.width)) for s in self.opciones]

    def on_click(self, gui):
        self.activo = not gui.submenu
        gui.submenu = not gui.submenu

    def update(self, key, gui):
        if self.activo:
            if key == curses.KEY_LEFT:
                self.id = max(self.id - 1, 0)
            elif key == curses.KEY_RIGHT:
                self.id = min(self.id + 1, len(self.opciones) - 1)

    def on_focus(self, page):
        if self.activo:
            draw(page, self.x, self.y, "< " + self.completas[self.id] + " >", 2)
        else:
            draw(page, self.x, self.y, "< " + self.completas[self.id] + " >", 3)

    def draw(self, page):
        draw(page, self.x, self.y, "< " + self.completas[self.id] + " >", 4)


class Gui:
    submenu = False

    def __init__(self):
        self.block = False
        self.controles = {}
        self.claves = []
        self.estaticos = []
        self.y = 0
        self.x = 0

    def add(self, control):
        if control.static:
            self.estaticos.append(control)
        else:
            if not (str(control.y) in self.controles):
                self.controles[str(control.y)] = []
            self.controles[str(control.y)].append(control)
            self.claves = sorted(map(int, self.controles.keys()))

    def draw(self):
        for y in self.controles.values():
            for v in y:
                if v.visible:
                    if v.focus:
                        v.on_focus(self.page)
                    else:
                        v.draw(self.page)
        for i in self.estaticos:
            if i.visible:
                i.draw(self.page)

    def update(self, key):
        for y in self.controles.values():
            for v in y:
                v.focus = False
        self.y = max(0, self.y)
        self.y = min(self.y, len(self.claves) - 1)
        self.x = max(0, self.x)
        self.x = min(self.x, len(self.controles[str(self.claves[self.y])]) - 1)
        self.controles[str(self.claves[self.y])][self.x].focus = True
        if not self.controles[str(self.claves[self.y])][self.x].disabled:
            if key == 10 or key == 13:
                self.controles[str(self.claves[self.y])][self.x].on_click(self)
            else:
                self.controles[str(self.claves[self.y])][self.x].update(key, self)

    def start(self, gui):
        pass

    def refresh(self):
        self.page.clear()
        self.draw()
        self.page.refresh()

    def main(self, page):
        self.page = page
        self.icons = {
            "ACS_BLOCK": curses.ACS_BLOCK,
            "ACS_BOARD": curses.ACS_BOARD,
            "ACS_BTEE": curses.ACS_BTEE,
            "ACS_BULLET": curses.ACS_BULLET,
            "ACS_CKBOARD": curses.ACS_CKBOARD,
            "ACS_DARROW": curses.ACS_DARROW,
            "ACS_DEGREE": curses.ACS_DEGREE,
            "ACS_DIAMOND": curses.ACS_DIAMOND,
            "ACS_GEQUAL": curses.ACS_GEQUAL,
            "ACS_HLINE": curses.ACS_HLINE,
            "ACS_LANTERN": curses.ACS_LANTERN,
            "ACS_LARROW": curses.ACS_LARROW,
            "ACS_LEQUAL": curses.ACS_LEQUAL,
            "ACS_LLCORNER": curses.ACS_LLCORNER,
            "ACS_LRCORNER": curses.ACS_LRCORNER,
            "ACS_LTEE": curses.ACS_LTEE,
            "ACS_NEQUAL": curses.ACS_NEQUAL,
            "ACS_PI": curses.ACS_PI,
            "ACS_PLMINUS": curses.ACS_PLMINUS,
            "ACS_PLUS": curses.ACS_PLUS,
            "ACS_RARROW": curses.ACS_RARROW,
            "ACS_RTEE": curses.ACS_RTEE,
            "ACS_S1": curses.ACS_S1,
            "ACS_S3": curses.ACS_S3,
            "ACS_S7": curses.ACS_S7,
            "ACS_S9": curses.ACS_S9,
            "ACS_SBBS": curses.ACS_SBBS,
            "ACS_SBSB": curses.ACS_SBSB,
            "ACS_SBSS": curses.ACS_SBSS,
            "ACS_SSBB": curses.ACS_SSBB,
            "ACS_SSBS": curses.ACS_SSBS,
            "ACS_SSSB": curses.ACS_SSSB,
            "ACS_SSSS": curses.ACS_SSSS,
            "ACS_STERLING": curses.ACS_STERLING,
            "ACS_TTEE": curses.ACS_TTEE,
            "ACS_UARROW": curses.ACS_UARROW,
            "ACS_ULCORNER": curses.ACS_ULCORNER,
            "ACS_URCORNER": curses.ACS_URCORNER,
            "ACS_VLINE": curses.ACS_VLINE,
        }
        curses.curs_set(0)
        curses.mousemask(1)
        curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_GREEN)
        curses.init_pair(3, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(4, curses.COLOR_WHITE, curses.COLOR_PAIRS)
        page.bkgd(curses.color_pair(1))
        for i in self.controles.values():
            for v in i:
                v.start(self)
        for v in self.estaticos:
            v.start(self)
        self.start(self)
        self.draw()
        while True:
            key = self.page.getch()
            if not self.submenu:
                if key == 27:
                    break
                if key == curses.KEY_DOWN:
                    self.y += 1
                if key == curses.KEY_UP:
                    self.y -= 1
                if key == curses.KEY_LEFT:
                    self.x -= 1
                if key == curses.KEY_RIGHT:
                    self.x += 1
            self.update(key)
            self.refresh()

    def mainloop(self):
        curses.wrapper(self.main)
