VERSION=3.4
DESTDIR=
PREFIX=/usr
PACKAGE=tksimsys

all:
	sed -i 's/@VERSION@/$(VERSION)/' $(PACKAGE).tcl

install:
	install -Dm755 $(PACKAGE).tcl $(DESTDIR)$(PREFIX)/bin/$(PACKAGE)
	for i in bitmaps/* pixmaps/* models/* ; do install -Dm644 $$i $(DESTDIR)$(PREFIX)/share/$(PACKAGE)/$$i ; done
	install -Dm644 $(PACKAGE).desktop $(DESTDIR)$(PREFIX)/share/applications/$(PACKAGE).desktop
	install -Dm644 $(PACKAGE).1 $(DESTDIR)$(PREFIX)/share/man/man1/$(PACKAGE).1

