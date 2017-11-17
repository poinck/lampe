# Readme: lampe

**lampe (-cli):**
bash-script to control your Philips Hue lights in interactive, oneshot or blind mode.

![lampe](/lampe.png)

**lampe-gtk:**
Control your Philips Hue lights from the Gnome-Desktop

![lampe-gtk](/lampe-gtk.png)

## Requirements
Following cli-tools need to be installed on your system in order to use **lampe (-bash)**:
- curl
- ping
- ip
- sed
- cut
- grep
- JSON.sh [v0.2.1](https://github.com/poinck/JSON.sh/tree/v0.2.1) forked, tested and branched from [dominictarr/JSON.sh](https://github.com/dominictarr/JSON.sh), later versions may work as well
- redshift
- bc (optional)

**lampe-gtk** has the following dependencies:
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
- If your version of redshift is compiled without geoclue-support than you have to add `redshift_options="-l xx.xx:yy.yy"` to your "~/.config/lampe/light-defaults" in order to have color temperature based on your location; a few examples:
```.sh
# redshift_options="-l 65.6:-36.6" # ammassalik, grönland
# redshift_options="-l 31:121" # shanghai
# redshift_options="-l 41:-87" # chicago
redshift_options="-l 52.52:13.40" # berlin
redshift_options="${redshift_options} -t 9500:1700"
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

**Docker image**
Build your Docker: [image](https://gist.github.com/wico/076ba6cf4c52c4dbf13f028e3c1872d4). Thx [wico](https://github.com/wico).

## Configuration
`lampe` will ask you for automatic discovery on first start. If the discovery fails, it will ask for the IP of the bridge. After that it will try to register itself at your Hue-bridge and ask you to press the Link-button. This should work with the new Hue-bridge api version which does not allow explicit user names anymore.

**Reset**

If the IP of the bridge has changed you can edit it in `~/.lamperc`. If that does not help you can reset the initial configuration by removing `~/.lamperc` and restart `lampe`.
```.sh
rm ~/.lamperc
```

## Usage: lampe (-bash)

**interactive mode**

Use "lampe" like a computer-game without gamepad or arrow-keys - use WASD. *(:*
See following list for more options:
```
1..99 - select light
    w - increase brightness
    a - lower saturation
    s - lower brightness
    d - increase saturation
 q, e - change hue-color
 y, Y - switch (all) lights on
 n, N - switch (all) lights off
 i, I - info: receive current or all light state(s)
 S, l - save and load user configuration
    F - find new lights
    r - start or stop random color sequence
    b - start or stop blinking sequence
    A - alert
    m - start or stop time based sequence
    t - start or stop redshift sequence
    o - start or stop noise sequnce
    Q - quit
```

**oneshot mode**

If you prefere that "lampe" just exists after changing a light setting, you can use the oneshot mode. All options can be used. The parameter LIGHT (number) is mandatory for all non-global options.
```.sh
lampe -s [LIGHT] OPTION
```

**blind mode**

If you have a very slow terminal, you can use the blind mode as follows; it won't show up the current light state unless you type "i" or "I". All other function are still accessible:
```.sh
lampe -b
```
