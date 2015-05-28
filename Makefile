default: compile

compile:
	# nothing to do here 

install:
	cp ./lampe /usr/bin/
	chmod a+rX /usr/bin/lampe
	
clean:
	# nothing to do here
	
uninstall:
	rm /usr/bin/lampe
