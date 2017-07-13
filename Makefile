.PHONY: all
all:
	ca65 80columns.s
	ca65 -o charset.o charset.s
	ld65 -C 80columns.cfg 80columns.o charset.o -o 80columns.bin
	printf "\0\310" > 80columns.prg
	cat 80columns.bin >> 80columns.prg
	exomizer sfx 51200 -q -n -o 80columns-compressed.prg 80columns.prg

.PHONY: clean
clean:
	rm -f *.prg *.bin *.o
