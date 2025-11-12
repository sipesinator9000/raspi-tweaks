# Introduction

---

---

These are my own instructions for fine-tuning a RetroPie into something with the quality of life features of a modern console.

This guide assumes that you are comfortable working in a command-line environment. Some of the optional features (particularly the optional LEDs and PWM fan controller) assume you are skilled at soldering.

High-level features:

- More snappy UI
- Nice looking, modern theme
- Silent cooling with tuned PWM fan controller
- Improved Power and Reset button behaviour
- Video shaders specific to each console
- Significantly improved boot and shutdown times (~36s and 2.5s respectively)
- Suite of custom testing tools

Optional features

- Controller screenshot button
- Addressable LEDs
- Selection of custom splashscreens
- Curated games list - not 6000 roms that won’t get played

## Terminology

---

Retropie: The operating system that everything runs on. Built on Raspbian.

Emulationstation: The frontend that you interact with when you’re not playing a game. It is one process that runs as a container with all of the emulation happening inside of it. Emulationstation contains all of the emulators, and launches the appropriate emulator (which you can fiddle with) when you launch a game. Most of the settings you’re going to edit during this process are changes to emulationstation.

Retroarch: 

## Emulation

---

When a developer takes a game and rejigs it to work with a different system, such as when a PC game is released for Xbox, the game is being *ported* to work with that console. The game is being altered to work with different hardware and a different OS. Emulation is when we don’t alter the game at all, but instead emulate the hardware that it natively ran on in order to play it.

Emulating 8-bit and 16-bit consoles is pretty easy. 

Emulating the N64 has always been a mess, and still is in some ways. This is because the hardware is particularly difficult to emulate. To get around this, many emulators are optimized for particular games rather than the system as a whole which can play anything. The result is that there are some games that run well and some that run terribly.

Retroarch contains emulators for many 8-bit and 16-bit systems. In some cases there are more than one emulator for a particular system, which can be configured in the run-comand window that 

## Hardware

---

This guide assumes you are using the following hardware:

- Raspberry Pi 3B+
- GeeekPi Pi heatsink and cooling fan kit
- RetroFlag Nespi Case +
- MiniMods fan control board
- Adafruit Trinket M0
- Adafruit Neopixel Stick 8

Additionally, you’ll need a monitor and a USB keyboard to do the initial setup. After wifi is connected and you can SSH into the pi, the rest can be done over SSH.

The reason why I’ve chosen an RPi3B+ for this build is because the 3B is the model I have the most experience with, and I think it provides the best value for money when building a retro game emulator for 16-bit game systems. These directions will also work for the Raspberry Pi 4 if you want your Pi to boot from an SSD rather than an SD card, and potentially emulate systems like the N64.

# Flash SD card with image

---

---

- Use the latest official Retropie image and follow the directions on the [official Retropie website](https://retropie.org.uk/download/).

# Initial setup

---

---

## Install RetroPie

---

Run retropie setup

- This is mainly automated. Run the script following the instructions here.

### Retropie Setup options

1. Enable SSH server
2. Connect to wifi

Some notes:

- You do not need to expand the filesystem! the ./retropie_setup.sh script already takes care of this for us as it is one of the first things this script does

## Raspi-tweaks

---

This repo contains a stress test, logging and debugging tools, and another script which installs a handful of tools and packages that I personally find useful, and some that are necessary for the rest of these directions to work. There is also a directory containing some custom splashscreens that I’ve created.

1. Clone the repo

`git clone [git@github.com](mailto:git@github.com):sipesinator9000/raspi-tweaks.git`

1. Run the install helper script to install a bunch of packages that will be useful for development, and some of the packages that are mentioned below for the fan speed controller and safe shutdown bits
2. Copy the custom splashscreens to the RetroPie splashscreens directory
    1. `cp ~/raspi-tweaks/splashscreens/ ~/Retropie/splascreens` 

# Install your roms

---

---

I recommend to do this step right away as some of the other setup bits require some roms to be installed first.

### Download roms

You’re on your own for this one

### Installing games

Copy the rom files from your computer to your retropie

`rsync -Prav ~/Desktop/roms/ alex@retropie:~/RetroPie/roms` 

### Scrape the game metadata

- The Retropie scraper can scrape from two different sources. Run both scrapers because some game metadata exists on one and not the other
- Do not edit the rom file name unless absolutely necessary. The scraper tools are expecting the sorts of file names that they will have in order to search its database.
- If both scrapers don’t contain metadata for your game, you can add that information manually by editing the `gamelist.xml` in each console’s respective folder located in `~/Retropie/.emulationstation/gamelists/<system>/gamelist.xml`
- Backup the game metadata

# Hardware Integration

---

---

As with all interactive systems, hardware integration is very important for creating a good user experience. These tweaks are to both integrate and tune hardware features to my preferences. You may find that you want to tweak some of the values suggested below.

## Nespi case and safe shutdown

---

1. Install [SafeShutdown.py](http://SafeShutdown.py) script
    1. Run the one-line installer from Retroflag github repo

The script lives in `/opt/RetroFlag/Safe_Shutdown.py` 

### Nespi case script modification (highly recommended)

---

The script that the RetroFlag case uses for its soft shutdown does the job, but not in the most clever way. The Power button waits way too long between killing emulationstation and actually shutting down the Pi, and the Reset button simply reboots the Pi. This is a bit annoying because the only reason you would be pressing the Reset button in the first place is to fix a frozen game. In this case, what you really want to do is just restart emulationstation. Emulationstation also takes <500ms to exit gracefully, so waiting any longer after that is pointless. The following modifications to the script address both of these things:

### **Speed up blinking Power LED**

---

1. For both the `LED on` and the `LED off` lines, change the number to .7s)

### **Fix the `Power` button logic**

---

1. Edit the list of commands that the power button executes to look like the following:

```arduino
killall emulationstation
sleep 2s
shutdown -q now
```

Note: This is killing emulationstation, pausing for 2s to allow it to exit gracefully, then shutting the Pi down whilst surpessing the noisey command line output. Between reducing the time delay and disabling some processes (below), we reduce the shutdown time considerably.

### **Fix the `Reset` button logic**

1. Edit the list of commands that the reset button executes to look like the following:

```arduino
killall emulationstation
sleep 2s
runuser -u $(USER) -- emulationstation
```

Note: This changes the reset button behaviour such that when it is pressed, we kill emulationstation, wait 2s for it to exit gracefully, then we’re starting it again as the current user without root privelages. We need to run the last command like this because the script itself is being run as `root`, and emulationstation cannot be run as root, so we need to run this as the `<user>` that’s set up. We can avoid needing to specify the user by passing the `$(USER)` environment variable. Reducing the sleep time just speeds things up because we can. However, keep in mind that the more roms you have installed on the system, the longer it will take for `emulationstation` to halt gracefully. 

## PWM Fan Controller [optional]

---

These directions are specifically for the [Mini-Mods fan controller board series](https://mini-mods.com/product-category/fan-control-kits/).

Their Github repo is [here](https://github.com/mafe72/NESPi-Fan-Control-Board?tab=readme-ov-file).

1. Install the fan controller directly with the following command: `wget -O - "https://github.com/mafe72/NESPi-Fan-Control-Board/raw/master/install.sh" | sudo bash`
2. Edit the fan controller script, which the installer should put in `/opt/MiniMods/fan_control.py`. Change the temperature thresholds to look like this:
    
    ```arduino
    offTEMP=10
    minTEMP=10
    midTEMP=50
    maxTEMP=85
    ```
    
    and the fan speeds in the `while` loop to look like this:
    
    ```arduino
    # Fan control
    while True:
            cpuTemp = int(float(getCPUtemp()))
            if cpuTemp >= minTEMP:
                    fan.start(40) #min duty cycle
            elif cpuTemp >= midTEMP:
                    fan.start(75) #mid duty cycle
            elif cpuTemp >= maxTEMP:
                    fan.start(99) #max duty cycle
            elif cpuTemp < offTEMP:
                    fan.stop()
            time.sleep(1.00)
    ```
    

Notes:

- I recommend using some form of PWM controller for whatever cooling fan you’re using, mainly to keep the noise down, but also to prolong the life of the fan itself. The fan speed settings ensure that the fan spins at one fixed speed during normal operation. A fan repeatedly changing speed is much more annoying than a fan that stays at the same speed. If the temperatures run away for any reason, the fan will speed up, but normal game emulation shouldn’t make the temps creep up beyond 45 degrees C.
- When powering off the pi, the service that runs this fan controller will exit just before the Pi itself powers off, so you will hear the fan spin up to full clip for a moment just before the Pi powers off.

## LEDs [optional]

---

I chose to mount both Adafruit modules to the ceiling of the Nespi case because:

- Everything is small and kept out of the way
- Integration and programming the LEDs is really easy
- Neopixels are addressable RGB LEDs, meaning that we can animate them in the future if we so desire.

Hardware:

- Adafruit Neopixel Stick 8
- Adafruit Trinket M0 microcontroller

Current, working code running the Neopixels:

```bash
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
```

## Overclocking!

---

---

Retropie benefits from buffs to CPU performance and RAM speed, which is why the overclocks and ram timing changes are so crucial in making the pi behave like a modern game console should. Emulating 8-bit and 16-bit games does not stress the GPU - Overclocking the `gpu_freq` or the `core_freq` will not increase performance, it will just make your system less stable.

Overclock raspi - [instructions and settings](https://www.reddit.com/r/raspberry_pi/comments/8c68ez/guide_how_to_overclock_raspberry_pi_3/)

[ExplainingComputers overclocking video](https://www.youtube.com/watch?v=SWl0n-uNdLc)

Some notes on overclocking:

- Ensue you had adequate cooling first before you even touch any overclocking values. Do some performance testing first and make sure that your temps are under control before you move on to overclocking.
- Be careful overclocking, and particularly overvolting. It is entirely possible to wind up with a boot config that doesn’t allow the pi to boot at all, and you’ll have to start again from scratch.
- Apply this modest and stable overclock profile that gives significant performance improvements in Retropie. Anything more ambitious is likely to give you a really unstable system.
- Make a backup of your boot config by saving `/boot/config.txt` backup as `.old` first

What A I has to say about clock speeds

`gpu_freq` is an overarching setting that adjusts all GPU-related frequencies, including `core_freq`, `h264_freq`, `isp_freq`, and `v3d_freq`. `core_freq` specifically controls the frequency of the GPU processor core and also impacts the L2 cache and memory bus, which can improve overall system performance, particularly on older models. For most overclocking, using `gpu_freq` is sufficient to change the overall GPU speed, while adjusting `core_freq` alone can be used for more targeted performance boosts

### Recommended OC Profile

For a Raspberry Pi 3B+

```bash
arm_freq=1500                   ## CPU max frequency
#gpu_freq=300                   ## GPU package max frequency
#core_freq=400                  ## Actual GPU speed
sdram_freq=520                  ## RAM max frequency
sdram_schmoo=0x02000020         ## RAM timings for more stable OC
over_voltage=2                  ## Voltage to the CPU
sdram_over_voltage=1            ## Voltage to the RAM
```

- Increases CPU clock speed and voltage
- Increases RAM clock speed and voltage
- Makes timing changes to the RAM to optimize for emulation

# Further Software Tweaking

---

---

## Theme and splashscreen

1. Run `/user/home/Retropie-Setup/retropie_setup.sh`
2. Download custom themes; install theme of your choosing
3. Choose splashscreen

## Disable unnecessary services

---

Disabling processes that aren’t needed to run a RetroPie console will significantly **speed up boot times** and give you slightly **more CPU and RAM headroom** for gaming.

1. Run `sudo systemctl list-units --type=process --state=running`
2. Check to see what unnecessary services we can potentially disable. Don’t disable anything that you don’t know you can safely disable. If in doubt, leave it alone.
3. Kill and then disable the following processes:

```bash
triggerhappy.service      # Some media player thing that isn't needed
smbd.service              # Filesharing stuff, not needed for rsync
nmbd.service              # Filesharing stuff, not needed for rsync
avahi-daemon.service      # Some file transfer service that isn't needed
avahi-daemon.service      # Another systemd unit that can start avahi-daemon
man-db.service            # Updates manual pages daily
```

`sudo systemctl stop <service_name.service>`

`sudo systemctl disable <service_name.service>` 

For an added layer of security to make sure other things can’t enable or start the service again:

`sudo systemctl mask <process_name.service>`

Test by rebooting the Pi and then running `sudo systemctl list-units --state=running` to see if any of these services are running. If any are running, run `sudo systemctl status <service_name.service>` to see if the service is still enabled. Consider disabling and masking the service.

## Disable the `run-command` window when launching games

---

This one is good to do if you like to mindlessly mash buttons while you’re waiting for games to launch. When this is disabled, the game will launch a few seconds quicker and you won’t accidentally enter an ugly menu that you don’t want to enter. This can always be re-enabled if you need to make tweaks to the emulators.

1. Enter the RetroPie menu in the main menu
2. Run the `retropie-setup` script
3. Select the run-command settings and disable it

## Get rid of noisy boot output

---

When the Raspberry Pi boots up, dmesg displays all sorts of output as the Pi boots up. This looks ugly and we don’t need to see it. Reducing the verbosity of dmesg output can speed up boot times as well. It also makes the RetroPie feel a bit more like a modern console and not a Raspberry Pi project. The scrolling text will be replaced with a simple blinking curser in the top-left of the screen.

### Disable Raspberry Pi splashscreen

---

1. Edit the `/boot/cmdline.txt` file in your favourite text editor.
2. Add the following things to the file:
    
    `quiet`
    
    `disable_splash=1` 
    

Note: This is a separate splashscreen to the RetroPie one below.

### Hush dmesg

---

Add the following line to `/etc/rc.local`

```bash
dmesg --console-off
```

This will keep dmesg printing of new kernel messages to the system's console.

### Hush systemd

---

Set loglevel=3 in `/boot/cmdline.txt`

This will only display errors, not the full systemd output

## Splashscreen

---

Some splashscreens that I’ve created are in this repo.

### Add a custom splashscreen when RetroPie boots up

1. Add splashscreens to the `~/Retropie/splashscreens` directory. They will now be available as options in the `retropie-config` menu.
2. Randomize your splashcreen? Or don’t. I’m not your dad.

### Reduce the time the splashscreen is displayed

The default splashscreen time in RetroPie is something ridiculous like 15 seconds. During this time nothing else is happening other than displaying an image. Reducing this will reduce the time it takes to boot into Emulationstation. You can edit this in the `retropie-config` menu, but only in 5 second increments. All this is doing is editing the file below, so we might as well just edit it manually to be even lower.

1. Edit this file `/opt/retropie/configs/all/splashscreen.cfg` to 2-3 sec

## Display Output Settings

---

These changes ensure that you won’t have a thick black border around everything, and you use the entire display.

Do not edit overcan settings in the Retroarch menu, only in the config file - Retroarch GUI tends to silently comment out lines in the config file and fuck with your shit.

Edit the display output section of `/boot/config.txt` to look like such:

```bash
# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
disable_overscan=1
overscan_scale=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
overscan_left=2
overscan_right=2
overscan_top=2
overscan_bottom=2
```

## Shaders

---

Shaders are colour profiles and patterns applied on top of the video output as layers. Retroarch has lots of shader presets built into it, and they can be assigned to default to particular games, systems, or globally.

Whether or not you turn on shaders is up to you. Some are more resource-intensive than others. At the very least, I recommend applying screen colour overlays for handheld consoles. The colours in those games were mixed in reference to the original hardware displays which were pretty desaturated, and you might find that colours are a bit too saturated without running a colour profile on a modern display.

Previews for the shaders can be found in [this github repo](https://github.com/libretro/shader-previews/).

Saving the core preset will cause all games on that particular system to launch with that preset automatically applied.

How to activate a shader

1. Launch a game
2. Press Select + X to enter the Retroarch config menu
3. Navigate to Shaders
4. Select a Preset
5. Select `Apply changes`

Set all games to a particular system to use a preset

1. Go to `Save Preset` > `Save Core Preset`

(`Core` is the term that Retroarch uses to refer to a console)

## Noisy SSH login output

---

Remove what you want from these files:

Static display text: `/etc/motd`

# Controllers

---

---

Some notes about controller choice:

- Get a comfy controller if you’re going to spend any significant amount of time playing retro games.
- Whatever controller you choose, I recommend going with something that uses [X-Input](https://www.reddit.com/r/pcgaming/comments/4zlbrx/what_is_the_difference_between_directinput_and/).
- Native controllers add a lot to the experience of retro games.
- Xbox controllers are very popular and ergonomic, and certainly have a place in this world, but they don’t belong anywhere near game emulators.
- 8BitDo has discontinued the NES30 and SFC30 controllers, which in my opinion are the most accurate controllers that they’ve ever produced. If you find one on Ebay, it is worth picking up.

## Set up a screenshot button

---

This portion of the directions will allow you to set up a controller button combination that will take a screenshot and save it to a directory that you specify. If you have a controller that allows you to assign a macro to one of the buttons, you can go one step further and make that button execute the screenshot button combination.

### Set a screenshot button macro

---

1. Create the screenshot directory you want to dump images to. It’s a good idea to just put it in the home directory.

`mkdir ~/screenshots`

1. Pair the controller.

1. Figure out which button is R3. This is a good button to use for screenshots because it is nonexistant in 16-bit and older systems, and therefore unlikely to be pressed by accident.
    1. Enter a game and launch the Retroarch settings by pressing `Select (hot key)` + `X`
    2. Navigate to `Controls` > `Port 1 Controls`
    3. Find R3 and note which button number it is mapped to on the game pad. This is the button you want to set as your `input_screenshot_btn` value in the next step.

1. Edit the Retroarch config to send screenshots the directory you just made, name them sequentially so each screenshot doesn’t overwrite the previous, and assign the screenshot button. (we will find this out in the Retroarch settings in the next step)

`/opt/retropie/configs/all/retroarch.cfg`

```bash
## Taking screenshots
# input_screenshot = f8
input_screenshot_btn = "11"
screenshot_directory = "/home/alex/screenshots"
auto_screenshot_filename = "true"
```

### Assign a screenshot button on the controller (8BitDo Pro 3)

---

In order to do this, you’ll need to use a controller like the 8BitDo Pro 3 which allows you to assign a macro to one of the buttons.

1. Download the 8BitDo firmware updater/configuration tool [here](https://app.8bitdo.com/Ultimate-Software-V2/).
2. Update your controller to the newest firmware
3. In the tool, set the Star button to run a macro of Select + R3. Set the duration (ms) to relatively low values

**Taking screenshots**

I like to map the screenshot macro to the Star button on the 8BitDo Pro 3. Provided that you’ve done the same, pressing the Star button should now execute a macro that triggers a screenshot in Retroarch, which is then saved in the directory that we pointed it to in the Retroarch config file.
