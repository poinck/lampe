BINDIR = $(DESTDIR)/usr/bin

# VALA_OPTS=-v --pkg gio-2.0 --target-glib 2.32 --pkg glib-2.0 --pkg posix
VALA_OPTS=-v --pkg gtk+-3.0 --pkg libsoup-2.4
CC_OPTS=-X -O2
SRC_FILES := $(wildcard src/*.vala) 

default: compile

compile:
	valac -g $(VALA_OPTS) $(CC_OPTS) $(SRC_FILES) -o lampe-gtk

install:
	install --mode=755 -d $(BINDIR)/
	install --mode=755 lampe $(BINDIR)/
	
clean:
	# nothing to do here
	
uninstall:
	rm $(BINDIR)/lampe
