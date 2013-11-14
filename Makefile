# Makefile for compiling the JSON lib on Harbour
#
# This is mostly for testing, it's better to use Harbour's internal functions:
# hb_jsonEncode
# hb_jsonDecode
#
# To the extent possible under law, Arthur Helfstein Fragoso has waived all copyright and related or neighboring rights to this Makefile.

HC=hbmk2

HFLAGS=-lhbct -i./include

all: libJSON.a

libJSON.a:
	$(HC) $(HFLAGS) lib/JSON.prg -hblib

clean:
	rm -rf libJSON.a
