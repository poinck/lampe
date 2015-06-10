# Readme: lampe
interactive bash-script to control your Philips hue lights.

![lampe](/lampe.png)

## Requirements
Following cli-tools need to be installed on your system in order to use "lampe"
- curl
- ping
- ip
- sed
- cut
- grep 
- JSON.sh (optional)
- bc (optional)
- zenity (optinal)

## Installation
If you want to use "lampe" system-wide, you can install it this way:
```.sh
make install # as root or use sudo, DESTDIR="/usr/bin"
```

**on Arch Linux:**
Thx to [FSMaxB](https://github.com/FSMaxB) there is an Arch package availabe in the AUR: 
```.sh
yaourt lampe
```

**on Gentoo Linux:**
Add my overlay ["koo"](https://github.com/poinck/koo) (instructions there) layman and than simply:
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

## Usage
Use "lampe" like a computer-game without gamepad or arrow-keys - use WASD. *(:*
```
1..99 - select light 
    w - increase brightness
    a - lower saturation
    s - lower brightness
    d - increase saturation
 q, e - change hue-color
 y, n - switch on, off
    z - open zenity-dialog to pick RGB-color 
    i - info: receive light state
 S, L - save and load user configuration (TODO)
    r - start or stop random sequence
    b - start or stop blinking sequence
    A - alert
    Q - quit
```

**oneshot mode**

"lampe" does support a graphical way to set a RGB color like this. The color will be choosen by the GTK color selection dialog powered by "zenity" (optional dependencies have to be installed on your system)
```.sh
lampe -z 2 # where 2 is the light number
```

**blind mode**

if you have a very slow terminal, you can use the blind mode as follows; it won't show up the current light state; everything else is still accessible:
```.sh
lampe -b
```

## TODOs
- [x] add support for hue to set color with "q" and "e"
- [x] help option
- [x] depricate use of "color", use native shell-escapes for colors in bash
- [x] special oneshot-mode to pick color with a GTK color selection dialog powered by "zenity" just for the @nylki
- [x] enable oneshot-mode while running in interactive-mode with "z"

**following** TODOs are set up as Github-issues:
- hue-bridge discovery (without using meethue.com/api/nupnp if possible) and user-configuration (~/.lamperc)
- write Makefile to install the script system-wide
- for the first major release: write ebuild for a Gentoo-overlay (which I need to provide anyway)
- on start get current light-settings from hue-bridge
- option "v" or (SHIFT)"S" to save current setting as new default for selected lamp and option "r" or (SHIFT)"R" to restore this default (needs user-configuration: store in bridge or in ~/.lamperc?)
