version := $(shell dpkg-parsechangelog -SVersion)
date    := $(shell date)

LANG_PO := ja
LANG_EN := en
LANGS := $(LANG_EN) $(LANG_PO)

all: version.ent $(LANGS)

en:
	debiandoc2html kernel-handbook.sgml

ja:
	po4a-translate -L EUC-JP -f sgml -m kernel-handbook.sgml -p po4a/kernel-handbook.ja.po -l kernel-handbook.ja.sgml
	debiandoc2html -lja_JP.eucJP kernel-handbook.ja.sgml

clean:
	rm -rf kernel-handbook.html
	$(foreach lng,$(LANGS), \
		rm -rf kernel-handbook.$(lng).html; \
		rm -rf kernel-handbook.$(lng).sgml; \
	)
	rm -rf pub

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!entity version "\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!entity version \"$(version)\">"	>> $@ &&	   \
		echo "<!entity date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	mkdir -p pub
	rm -f pub/*
	cp htaccess pub/.htaccess
	$(foreach lng,$(LANGS), \
	for html in kernel-handbook$(subst .en,,.$(lng)).html/*.html; do \
		ln -s ../$$html pub/$$(basename $$html).$(lng); \
	done; \
	echo 'AddLanguage $(lng) .$(lng)' >>pub/.htaccess; \
	)
	rsync -v -e ssh --chmod=a+rX --times --omit-dir-times --recursive \
		--copy-links --delete pub/ \
		alioth.debian.org:/var/lib/gforge/chroot/home/groups/kernel-handbook/htdocs/

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f sgml -m kernel-handbook.sgml -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all sync FORCE
