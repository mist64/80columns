.PHONY: all
all: 80columns-compressed.prg 80c2-compressed.prg 80c3-compressed.prg 80c4-compressed.prg

%-compressed.prg: %-uncompressed.prg
	exomizer sfx 51200 -q -n -o $@ $<

%-uncompressed.prg: %.bin
	(printf '\0\310'; cat $<) > $@

.INTERMEDIATE: 80columns.bin
80columns.bin: 80columns.o charset.o 80columns.cfg
	ld65 -C 80columns.cfg $(filter %.o,$^) -o $@

80c%.bin: 80columns.o charset%.o 80columns.cfg
	ld65 -C 80columns.cfg $(filter %.o,$^) -o $@

%.o: %.s
	ca65 -o $@ $<

.PHONY: clean
clean:
	rm -f *.prg *.bin *.o
