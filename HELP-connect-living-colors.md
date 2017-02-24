# Help: Connect living color lights

Unterstützt werden alle Philips Living Colors-Lampen der zweiten oder dritten Generation.

**1.**
Im ersten Schritt müssen Sie die Fernbedienung der Living Colors-Lampen auf den Auslieferungszustand zurücksetzen. Das funktioniert, indem Sie den Batteriedeckel öffnen und mit einem Gegenstand wie einer Büroklammer den Reset-Button drücken.

Danach müssen Sie auf der Fernbedienung für fünf Sekunden die beiden Buttons 0 und * gedrückt halten. 

**2. reset bridge (optional)** 
Im zweiten Schritt gilt es auch die Philips Hue-Bridge auf den Auslieferungszustand zurückzusetzen. Klicken Sie dazu mit einem Stift (o.ä.) auf den Reset-Knopf auf der Unterseite der Bridge.

**3. connect living color remote control to Hue bridge**
Legen Sie nun die Living Colors-Fernbedienung direkt neben die Hue-Bridge und drücken Sie auf den Frontbutton der Bridge.

Jetzt an der Fernbedienung gleichzeitig die Buttons I und Fav1 (Button links unten) drücken, bis die Bridge nicht mehr blau leuchtet.

**4. learn living color lights**
Nun gilt es, die frische Fernbedienung neu anzulernen. Halten Sie dazu die Living Colors-Fernbedienung in die Nähe Ihrer angeschalteten Living Colors-Lampen und halten Sie den Button I so lange gedrückt, bis die Lampe in verschiedenen Farben drei Mal aufblinkt.

Wer mehrere Living Colors-Lampen besitzt, geht nun genauso fort: Fernbedienung an die Leuchte halten und den Button I so lange drücken, bis die LEDs drei Mal blinken.

**5. learn Hue lights**
Genau so gehen Sie jetzt auch bei den Hue-Birnen vor: Fernbedienung in die Nähe der eingeschraubten und abgeschalteten LED-Lampen halten und den Button I so lange drücken, bis die LEDs drei Mal blinken.

**6.**
Haben Sie alle LED-Leuchten eingelernt, halten Sie im letzten Schritt nun die Living Colors-Fernbedienung wieder in die Nähe der Hue-Bridge, drücken dort einmal auf den Front-Button und halten danach so lange den I-Button der Fernbedienung, bis die Bridge wieder blau leuchtet.

The Hue bridge will find new lights *only* if they have been connected to the living color remote first. (unsure)

**7. find all new lights with Hue bridge**
(this will be a new function for "lampe")

```.sh
curl http://<brigde-ip>/api/lampe-bash/lights -X POST 
	# wait one minute, redo if you have added more than 15 lights
curl http://<brigde-ip>/api/lampe-bash/lights -X GET  
	# to see if that worked
```

After that all lights, including the living color lights should be accessible through "lampe".
