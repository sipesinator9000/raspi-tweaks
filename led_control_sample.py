import board
import digitalio
import time
import neopixel

led = digitalio.DigitalInOut(board.D13)
led.direction = digitalio.Direction.OUTPUT
pixel_pin = board.D1
num_pixels = 8
pixels = neopixel.NeoPixel(pixel_pin, num_pixels, brightness=0.3, auto_write=False)

RED = (255, 0, 0)
BLUE = (0, 0, 255)
PURPLE = (128, 0, 128)
ORANGE = (255, 30, 0)
GREEN = (0, 255, 0)
CYAN = (0, 255, 90)
PINK = (255, 0, 80)

blink = Blink(pixels, speed=0.5, color=RED)
comet = Comet(pixels, speed=0.01, color=GREEN, tail_length=10, bounce=False)
chase = Chase(pixels, speed=0.1, size=3, spacing=6, color=BLUE)

animations = AnimationSequence(blink, comet, chase, advance_interval=3, auto_clear=True)

while True:
    animations.animate()