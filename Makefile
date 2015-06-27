BINDIR = $(DESTDIR)/usr/bin

# VALA_OPTS=-v --pkg gio-2.0 --target-glib 2.32 --pkg glib-2.0 --pkg posix
# --target-glib=2.42
VALA_OPTS=-v --pkg gtk+-3.0 --pkg libsoup-2.4 --pkg json-glib-1.0 
CC_OPTS=-X -g 
SRC_FILES := $(wildcard src/*.vala) 

LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

default: compile

compile:
	valac -v -g $(VALA_OPTS) $(CC_OPTS) $(SRC_FILES) -o lampe-gtk

install:
	install --mode=755 -d $(BINDIR)/
	install --mode=755 lampe $(BINDIR)/
	
clean:
	# nothing to do here
	
uninstall:
	rm $(BINDIR)/lampe
