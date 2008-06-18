test:
	for f in `find GuitarPro -name '*.pm'`; do perl -c $$f; done

install:
	mkdir $(DESTDIR)/usr/share/perl5
	cp -r GuitarPro $(DESTDIR)/usr/share/perl5/
