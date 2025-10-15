## TODO ##
# - put this in its own repo
# - write my own installer
#
# Wiring:
#  GPIO 2  Reset Button (INPUT)
#  GPIO 3  Power Button (INPUT)
#  GPIO 14 LED on signal (OUTPUT)
#
#####################################
#  Install these libraries first
#  sudo apt-get install python-dev python-pip python-gpiozero
#  sudo pip install psutil pyserial
#####################################

import RPi.GPIO as GPIO
import time
import os
import socket
from gpiozero import Button, LED
GPIO.setmode(GPIO.BCM)

resetButton = Button(2)
powerButton = Button(3)

led = LED(14)

resetBtn = Button(resetButton, hold_time=2)
GPIO.setup(resetButton,GPIO.IN, pull_up_down=GPIO.PUD_UP)

while True:
	## POWER button
	## When power button is unlatched, kill emulationstation and then run shutdown command
	if not powerButton.is_pressed:
		led.blink(.06,.06)
		os.system("sudo killall emulationstation")
		os.system("sudo sleep 0.5s")
		os.system("shutdown -h now")
	else:
		led.on()
		

	## RESET Button pressed
	## Restart emulationstation process
	if resetBtn.is_pressed:
		os.system("sudo killall emulationstation")
		os.system("sudo sleep 0.5s")
		os.system("emulationstation")


	## RESET Button held
	## LEDs flash rapidly and console is rebooted
	if resetBtn.is_held:
		led.blink(0.06,0.06)
		os.system("sudo killall emulationstation")
		os.system("sudo reboot -h now")