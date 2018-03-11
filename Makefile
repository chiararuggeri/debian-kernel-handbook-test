ifneq ($(shell dpkg-parsechangelog -SDistribution),UNRELEASED)
# Use changelog version and date for a release
version := $(shell dpkg-parsechangelog -SVersion)
date    := $(shell date -u -d "$$(dpkg-parsechangelog -SDate)")
else
# Use git commit description and date otherwise
version := $(shell git describe)
date    := $(shell date -u -d "@$$(git log --pretty='%cd' --date=unix HEAD -1)")
endif

LANG_PO := ja
LANG_EN := en
LANGS := $(LANG_EN) $(LANG_PO)

SOURCES := kernel-handbook.dbk $(wildcard chapter-*.dbk)

# Ensure xmlto uses UTF-8 and not numbered entities
unexport LC_ALL
export LC_CTYPE=C.UTF-8

all: version.ent $(LANGS)

en:
	xmlto -o kernel-handbook.html -m stylesheet.xsl html kernel-handbook.dbk

ja:
	mkdir -p kernel-handbook.ja.dbk
	ln -sf ../version.ent kernel-handbook.ja.dbk/
	for src in $(SOURCES); do \
		po4a-translate -f docbook -m "$$src" -p po4a/kernel-handbook.ja.po -k 0 -l kernel-handbook.ja.dbk/"$$src" || exit; \
	done
	xmlto -o kernel-handbook.ja.html -m stylesheet.xsl html kernel-handbook.ja.dbk/kernel-handbook.dbk

clean:
	rm -rf kernel-handbook.html
	$(foreach lng,$(LANGS), \
		rm -rf kernel-handbook.$(lng).html; \
		rm -rf kernel-handbook.$(lng).dbk; \
	)
	rm -rf pub
	rm -f version.ent

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!ENTITY version *"\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!ENTITY version \"$(version)\">"	>> $@ &&	   \
		echo "<!ENTITY date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	mkdir -p pub
	rm -f pub/*
	cp htaccess pub/.htaccess
	$(foreach lng,$(LANGS), \
	for html in kernel-handbook$(subst .en,,.$(lng)).html/*.html; do \
		cp $$html pub/$$(basename $$html).$(lng); \
	done; \
	echo 'AddLanguage $(lng) .$(lng)' >>pub/.htaccess; \
	)
	chmod -R a+rX pub
	rsync -v -e ssh --perms --times --omit-dir-times --recursive \
		--copy-links --delete pub/ \
		shadbolt.decadent.org.uk:/usr/local/website/debian-kernel-handbook/

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f docbook $(patsubst %,-m %,$(SOURCES)) -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all sync FORCE
