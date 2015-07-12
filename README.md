# Readme: lampe

**lampe-gtk:**
Control your Philips Hue lights from the Gnome-Desktop

![lampe-gtk](/lampe-gtk.png)

**lampe(-bash):**
Interactive bash-script to control your Philips Hue lights.

![lampe](/lampe.png)

## Requirements
Following cli-tools need to be installed on your system in order to use "lampe"
- curl
- ping
- ip
- sed
- cut
- grep 
- JSON.sh
- bc (optional)

"lampe-gtk" has the following dependencies:
- libsoup
- gtk3
- json-glib
- vala

## Installation
If you want to use "lampe" system-wide, you can install it this way:
```.sh
make
make install # as root or use sudo
```

**on Arch Linux:**
Thx to [FSMaxB](https://github.com/FSMaxB) there is an Arch package availabe in the AUR: 
```.sh
yaourt lampe
```

**on Gentoo Linux:**
Add my overlay ["koo"](https://github.com/poinck/koo) (instructions there) with layman and than simply:
```.sh
emerge -av lampe
```

## Configuration
"lampe" will ask you for automatic discovery on first start. If you cannot use automatic discovery in your network or detection fails, you can enter the IP of your bridge manually. After that it will try to register the user "lampe-bash" at your Hue-bridge and ask you to press the Link-button.  

**Problems?**

If you cannot enter the IP interactively, you can create the file "~/.lamperc" with following content (for now it is not possible to register a user if you create this file yourself):
```.sh
bridgeip="192.168.?.?" # replace ? with respective IP bytes
```

**Reset**

To reset the per user configuration, remove '.lamperc' from your home-directory:
```.sh
rm ~/.lamperc
```

## Usage: lampe(-bash)
Use "lampe" like a computer-game without gamepad or arrow-keys - use WASD. *(:*
```
1..99 - select light 
    w - increase brightness
    a - lower saturation
    s - lower brightness
    d - increase saturation
 q, e - change hue-color
 y, n - switch on, off
 i, I - info: receive current or all light state(s)
 S, l - save and load user configuration
    F - find new lights
    r - start or stop random color sequence
    b - start or stop blinking sequence
    A - alert
    m - start or stop temperature difference based color sequence
    Q - quit
```

**blind mode**

if you have a very slow terminal, you can use the blind mode as follows; it won't show up the current light state, but everything else is still accessible:
```.sh
lampe -b
```
