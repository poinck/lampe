# Readme: lampe
interactive bash-script to control up to 9 hue-lamps.

## Requirements
Following cli-tools need to be installed on your system in order to use "lampe"
- curl
- color

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
```

### example output 
``` 
   [======--PRESS-h-FOR-HELP--------------------------]
      w,s   BRIGHTNESS   -
      a,d   SATURATION   =
      q,e   COLOR        o
      1..9  LAMP
 1 [===o========================------                ] off 
```

## TODOs
- [x] add support for hue to set color with Q and E
- [ ] hue-bridge discovery (without using meethue.com/api/nupnp if possible) and user-configuration
- [x] help option
- [ ] on start get current light-settings from hue-bridge
