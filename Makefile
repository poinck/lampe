BINDIR = $(DESTDIR)/usr/bin
PIXDIR = $(DESTDIR)/usr/share/pixmaps
MENDIR = $(DESTDIR)/usr/share/applications

VALAC = valac
DEBUG = 0

VALA_OPTS = -v --pkg gtk+-3.0 --pkg libsoup-2.4 --pkg json-glib-1.0 --pkg posix --target-glib=2.42 --pkg glib-2.0
CC_OPTS = -X -lm

VALA_DEBUG_OPTS =
CC_DEBUG_OPTS =
ifeq ($(DEBUG), 1)
VALA_DEBUG_OPTS = -g -D DEBUG -D TEST
CC_DEBUG_OPTS = -X -g
endif

SRC_FILES := $(wildcard src/*.vala)

LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

default: lampe-gtk

lampe-gtk:
	$(VALAC) $(VALA_DEBUG_OPTS) $(VALA_OPTS) $(CC_OPTS) $(CC_DEBUG_OPTS) $(SRC_FILES) -o lampe-gtk

install: lampe-gtk
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
