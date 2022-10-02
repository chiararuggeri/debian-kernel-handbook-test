ifneq ($(shell dpkg-parsechangelog -SDistribution),UNRELEASED)
# Use changelog version and date for a release
version := $(shell dpkg-parsechangelog -SVersion)
date    := $(shell dpkg-parsechangelog -SDate)
else
# Use git commit hash and date otherwise
date    := $(if $(CI_COMMIT_TIMESTAMP),$(CI_COMMIT_TIMESTAMP),@$(shell git log --pretty='%cd' --date=unix HEAD -1))
commit  := $(if $(CI_COMMIT_SHA),$(shell printf '%.7s' '$(CI_COMMIT_SHA)'),$(shell git rev-parse --short=7 HEAD))
version := $(shell dpkg-parsechangelog -SVersion -o1 -c1)+git$(shell LC_ALL=C date -u -d '$(date)' +%Y%m%d).$(commit)
endif
# Convert date to fixed format
date    := $(shell LC_ALL=C date -u -d '$(date)')

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

stamps/build-%: $(SOURCES) po4a/kernel-handbook.%.po
	mkdir -p kernel-handbook.$*.dbk
	ln -sf ../version.ent kernel-handbook.$*.dbk/
	for src in $(DOCBOOK_SOURCES); do \
		po4a-translate -f docbook -m "$$src" -p po4a/kernel-handbook.$*.po -k 0 -l kernel-handbook.$*.dbk/"$$src" || exit; \
	done
	xmlto -o kernel-handbook.$*.html -m stylesheet.xsl html kernel-handbook.$*.dbk/kernel-handbook.dbk
	mkdir -p $(@D)
	touch $@

clean:
	rm -rf kernel-handbook.html
	$(foreach lng,$(LANGS), \
		rm -rf kernel-handbook.$(lng).html; \
		rm -rf kernel-handbook.$(lng).dbk; \
	)
	rm -rf stamps
	rm -f version.ent

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!ENTITY version *"\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!ENTITY version \"$(version)\">"	>> $@ &&	   \
		echo "<!ENTITY date    \"$(date)\">"    >> $@;		   \
	fi

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f docbook $(patsubst %,-m %,$(DOCBOOK_SOURCES)) -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all clean po-update FORCE
