# Readme: lampe
interactive bash-script to control up to 9 hue-lamps.

![lampe](/lampe.png)

## Requirements
Following cli-tools need to be installed on your system in order to use "lampe"
- curl
- ping
- ip
- sed
- cut
- grep 
- bc (optional)
- zenity (optinal)

## Installation (optional)
It is planned to provide an install-script using a Makefile

## Configuration
This script does not register a user on the hue-bridge, yet. See [Getting Started at meethue.com](http://www.developers.meethue.com/documentation/getting-started) to enable developer-mode. After that you can start "lampe" in a shell. It will ask you for automatic discovery. If you cannot use automatic discovery in your network or detection fails, you can enter the IP of your bridge manually. If you cannot enter the IP interactively, you can create the file "~/.lamperc" with following content:
```.sh
bridgeip="192.168.?.?" # replace ? with respective IP bytes
```

**Reset**

To reset the configuration, remove '.lamperc' from your home-directory:
```.sh
rm ~/.lamperc
```

## Usage
Use "lampe" like a computer-game without gamepad or arrow-keys - use WASD. *(:*
```
  w - increase brightness
  a - lower saturation
  s - lower brightness
  d - increase saturation
q,e - change hue-color
  z - open zenity-dialog to pick RGB-color 
```

**oneshot mode**

"lampe" does support a graphical way to set a RGB color like this. The color will be choosen by the GTK color selection dialog powered by "zenity" (optional dependencies have to be installed on your system)
```.sh
./lampe -z 2 # where 2 is the lamp-number
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
