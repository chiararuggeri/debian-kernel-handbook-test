version := 1.0.5
date    := $(shell date)

all: version.ent
	debiandoc2html kernel-handbook.sgml

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!entity version "\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!entity version \"$(version)\">"	>> $@ &&	   \
		echo "<!entity date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	rsync -v -e ssh kernel-handbook.html/* alioth.debian.org:/var/lib/gforge/chroot/home/groups/kernel-handbook/htdocs/

.PHONY: all sync FORCE
