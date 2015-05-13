# Readme: lampe
interactive bash-script to control up to 9 hue-lamps.

![lampe](/lampe.png)

## Requirements
Following cli-tools need to be installed on your system in order to use "lampe"
- curl
- bc (optional)
- zenity (optinal)

## Configuration
This script does not register a user on the hue-bridge; see [Getting Started at meethue.com](http://www.developers.meethue.com/documentation/getting-started). After that you should set the IP of your bridge by modifying the variable "bridgeip" inside the "lampe"-script with your favourite editor.
```.sh
bridgeip="192.168.?.???"
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
**example output**
 
``` 
   [======--PRESS-h-FOR-HELP--------------------------]
      w,s   BRIGHTNESS   -
      a,d   SATURATION   =
      q,e   COLOR        C
      1..9  LAMP
      z     ZENITY
 1 [===C========================------                ] off 
```

**oneshot mode**

"lampe" does support a graphical way to set a RGB color like this. The color will be choosen by the GTK color selection dialog powered by "zenity" (optional dependencies have to be installed on your system)
```.sh
./lampe -z 2 # where 2 is the lamp-number
```

## TODOs
- [x] add support for hue to set color with "q" and "e"
- [ ] hue-bridge discovery (without using meethue.com/api/nupnp if possible) and user-configuration (~/.lamperc)
- [x] help option
- [ ] on start get current light-settings from hue-bridge
- [x] depricate use of "color", use native shell-escapes for colors in bash
- [ ] option "v" or (SHIFT)"S" to save current setting as new default for selected lamp and option "r" or (SHIFT)"R" to restore this default (needs user-configuration: store in bridge or in ~/.lamperc?)
- [x] special oneshot-mode to pick color with a GTK color selection dialog powered by "zenity" just for the @nylki
- [x] enable oneshot-mode while running in interactive-mode with "z"
- [ ] write Makefile to install the script system-wide
- [ ] for the first major release: write ebuild for a Gentoo-overlay (which I need to provide anyway)
