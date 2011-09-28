version := 1.0.12
date    := $(shell date)

all: version.ent
	debiandoc2html kernel-handbook.sgml

clean:
	rm -rf kernel-handbook.html

version.ent: FORCE
	if [ "$(version)" !=						   \
	     "$$(sed 's/<!entity version "\(.*\)">/\1/; t; d' $@)" ]; then \
		rm -f $@ &&						   \
		echo "<!entity version \"$(version)\">"	>> $@ &&	   \
		echo "<!entity date    \"$(date)\">"    >> $@;		   \
	fi

sync:
	rsync -v -e ssh --chmod=a+rX --times kernel-handbook.html/* alioth.debian.org:/var/lib/gforge/chroot/home/groups/kernel-handbook/htdocs/

.PHONY: all sync FORCE
