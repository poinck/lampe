# Readme: lampe
personal bash-script to control 3 hue-lamps.

## Configure
This script does not register a user on the huw-bridge; see [Getting Started at meethue.com](http://www.developers.meethue.com/documentation/getting-started). After that you should set the IP of your bridge like this: 
```.sh
cd # to location of the lampe-script
vim lampe
2j
12l
i
# enter the IP of your hui-bridge
:wq
```
## Usage
Than you can use the script like following to set the predefined color for your livingroom (w = "Wohnzimmer"):
```.sh
lampe w
```
or switch off the lamp in your sleeping (s = "Schlafzimmer") room like this:
```.sh
lampe s off
```
