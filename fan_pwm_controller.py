## Define fan temperature ranges
offTEMP=10
minTEMP=10
midTEMP=50
maxTEMP=85

#GPIO 17 default Fan ON/OFF Signal
fanGPIO=17

import RPi.GPIO as GPIO
import time
import os
import socket

GPIO.setmode(GPIO.BCM)
GPIO.setup(fanGPIO, GPIO.OUT)

fan = GPIO.PWM(fanGPIO, 50) #PWM frequency set to 50Hz

# CPU temp
def getCPUtemp():
        res = os.popen('vcgencmd measure_temp').readline()
        return (res.replace("temp=","").replace("'C\n",""))

# Fan control
while True:
        cpuTemp = int(float(getCPUtemp()))
        if cpuTemp >= minTEMP:
                fan.start(40) #min duty cycle
        elif cpuTemp >= midTEMP:
                fan.start(75) #mid duty cycle
        elif cpuTemp >= maxTEMP:
                fan.start(95) #max duty cycle
        elif cpuTemp < offTEMP:
                fan.stop()
        time.sleep(1.00)