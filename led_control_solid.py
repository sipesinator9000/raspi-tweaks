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


while True:
    pixels.fill(RED)
    pixels.show()