BINDIR = $(DESTDIR)/usr/bin
PIXDIR = $(DESTDIR)/usr/share/pixmaps
MENDIR = $(DESTDIR)/usr/share/applications

VALAC ?= valac

# VALA_OPTS=-v --pkg gio-2.0
VALA_OPTS = -v --pkg gtk+-3.0 --pkg libsoup-2.4 --pkg json-glib-1.0 --pkg posix --target-glib=2.42 --pkg glib-2.0
CC_OPTS = -X -lm
SRC_FILES := $(wildcard src/*.vala)

LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

default: compile

compile:
	$(VALAC) $(VALA_OPTS) $(CC_OPTS) -X -O3 $(SRC_FILES) -o lampe-gtk

compile_debug:
	$(VALAC) -g -D DEBUG -D TEST $(VALA_OPTS) $(CC_OPTS) -X -g $(SRC_FILES) -o lampe-gtk

install:
	install --mode=755 -d $(BINDIR)/
	install --mode=755 lampe $(BINDIR)/
	install --mode=755 lampe-gtk $(BINDIR)/

	install --mode=755 -d $(PIXDIR)/
	install --mode=655 lampe-icon.png $(PIXDIR)/

	install --mode=755 -d $(MENDIR)/
	install --mode=655 lampe.desktop $(MENDIR)/

clean:
	rm lampe-gtk

uninstall:
	rm $(BINDIR)/lampe
	rm $(BINDIR)/lampe-gtk
	rm $(PIXDIR)/lampe-icon.png
	rm $(MENDIR)/lampe.desktop
