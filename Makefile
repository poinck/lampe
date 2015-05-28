default: compile

compile:
	# nothing to do here 

install:
	cp ./lampe $(DESTDIR)usr/bin
	chmod a+rX $(DESTDIR)usr/bin/lampe
	
clean:
	# nothing to do here
	
uninstall:
	rm $(DESTDIR)usr/bin/lampe
