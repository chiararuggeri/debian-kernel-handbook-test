version := 1.0.0
date    := $(shell date)

all: version.ent
	debiandoc2html kernel-handbook.sgml

version.ent: 
	rm -f $@
	echo "<!entity version \"$(version)\">" >> $@
	echo "<!entity date    \"$(date)\">"    >> $@

sync:
	rsync -v -e ssh kernel-handbook.html/* jurij-guest@alioth.debian.org:/var/lib/gforge/chroot/home/groups/kernel-handbook/htdocs/

.PHONY: all sync
