BINDIR = $(DESTDIR)/usr/bin

default: compile

compile:
	# nothing to do here 

install:
	# cp ./lampe $(DESTDIR)
	# chmod a+rX $(DESTDIR)/lampe
	install --mode=755 -d $(BINDIR)/
	install --mode=755 lampe $(BINDIR)/
	
clean:
	# nothing to do here
	
uninstall:
	rm $(BINDIR)/lampe
