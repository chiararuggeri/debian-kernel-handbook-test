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

DOCBOOK_SOURCES := kernel-handbook.dbk $(wildcard chapter-*.dbk)
SOURCES := $(DOCBOOK_SOURCES) stylesheet.xsl version.ent

# Ensure xmlto uses UTF-8 and not numbered entities
unexport LC_ALL
export LC_CTYPE=C.UTF-8

all: $(patsubst %,stamps/build-%,$(LANGS))

stamps/build-en: $(SOURCES)
	xmlto -o kernel-handbook.html -m stylesheet.xsl html kernel-handbook.dbk
	mkdir -p $(@D)
	touch $@

stamps/build-ja: $(SOURCES) po4a/kernel-handbook.ja.po
	mkdir -p kernel-handbook.ja.dbk
	ln -sf ../version.ent kernel-handbook.ja.dbk/
	for src in $(DOCBOOK_SOURCES); do \
		po4a-translate -f docbook -m "$$src" -p po4a/kernel-handbook.ja.po -k 0 -l kernel-handbook.ja.dbk/"$$src" || exit; \
	done
	xmlto -o kernel-handbook.ja.html -m stylesheet.xsl html kernel-handbook.ja.dbk/kernel-handbook.dbk
	mkdir -p $(@D)
	touch $@

clean:
	rm -rf kernel-handbook.html
	$(foreach lng,$(LANGS), \
		rm -rf kernel-handbook.$(lng).html; \
		rm -rf kernel-handbook.$(lng).dbk; \
	)
	rm -rf pub stamps
	rm -f version.ent

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!ENTITY version *"\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!ENTITY version \"$(version)\">"	>> $@ &&	   \
		echo "<!ENTITY date    \"$(date)\">"    >> $@;		   \
	fi

sync: all
	git diff --quiet HEAD ||					\
	{ echo >&2 "E: Working tree has uncommitted changes"; exit 1; }
	status="$$(git status -b --porcelain)";				\
	[ "$${status%\?\? *}" = "$$status" ] ||				\
	{ echo >&2 "E: Working tree has files that are untracked and not ignored"; exit 1; }; \
	head="$${status#\#\# }";						\
	[ "$${head%...*}" = master ] || 					\
	{ echo >&2 "E: You should only sync from the master branch"; exit 1; }
	git checkout -B pages
	rm -rf public
	cp -R kernel-handbook.html public
	git add -f public
	git commit -m "Add HTML output"
	git push -f origin pages
	git checkout master

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f docbook $(patsubst %,-m %,$(DOCBOOK_SOURCES)) -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all clean po-update sync FORCE
