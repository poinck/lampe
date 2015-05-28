default: compile

compile:
	# nothing to do here 

install:
	cp ./lampe $(DESTDIR)
	chmod a+rX $(DESTDIR)/lampe
	
clean:
	# nothing to do here
	
uninstall:
	rm $(DESTDIR)/lampe
