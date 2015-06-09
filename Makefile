BINDIR = $(DESTDIR)/usr/bin

default: compile

compile:
	# nothing to do here 

install:
	install --mode=755 -d $(BINDIR)/
	install --mode=755 lampe $(BINDIR)/
	
clean:
	# nothing to do here
	
uninstall:
	rm $(BINDIR)/lampe
