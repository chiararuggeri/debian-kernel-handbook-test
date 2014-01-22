version := $(shell dpkg-parsechangelog | sed -ne 's,^Version: *\(.*\)$$,\1,p')
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

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!entity version "\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!entity version \"$(version)\">"	>> $@ &&	   \
		echo "<!entity date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	rsync -v -e ssh --chmod=a+rX --times kernel-handbook.html/* alioth.debian.org:/var/lib/gforge/chroot/home/groups/kernel-handbook/htdocs/

po-update:
	$(foreach lng,$(LANG_PO), \
	po4a-updatepo -f sgml -m kernel-handbook.sgml -p po4a/kernel-handbook.$(lng).po; \
	)

.PHONY: all sync FORCE
