version := $(shell dpkg-parsechangelog -SVersion)
date    := $(shell date -d "$$(dpkg-parsechangelog -SDate)")

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

version.ent: FORCE
	if [ "$(date)" !=						   \
	     "$$(sed 's/<!ENTITY date *"\(.*\)">/\1/; t; d' $@)" ]; then   \
		rm -f $@ &&						   \
		echo "<!ENTITY version \"$(version)\">"	>> $@ &&	   \
		echo "<!ENTITY date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	git diff --quiet HEAD ||					\
	{ echo >&2 "E: Working tree has uncommitted changes"; exit 1; }
	status="$$(git status -b --porcelain)";				\
	[ "$${status%\?\? *}" = "$$status" ] ||				\
	{ echo >&2 "E: Working tree has files that are untracked and not ignored"; exit 1; }; \
	head="$${status#\#\# }";						\
	[ "$${head%...*}" = master ] || 					\
	{ echo >&2 "E: You should only sync from the master branch"; exit 1; }
	git checkout -B pages
	mkdir -p pub
	rm -f pub/*
	cp htaccess pub/.htaccess
	$(foreach lng,$(LANGS), \
	for html in kernel-handbook$(subst .en,,.$(lng)).html/*.html; do \
		ln -s ../$$html pub/$$(basename $$html).$(lng); \
	done; \
	echo 'AddLanguage $(lng) .$(lng)' >>pub/.htaccess; \
	)
	git add -f pub
	git commit -m "Add HTML output"
	git push -f origin pages
	git checkout master

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f docbook $(patsubst %,-m %,$(SOURCES)) -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all sync FORCE
