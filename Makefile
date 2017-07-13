.PHONY: all
all: 80columns-compressed.prg 80c2-compressed.prg 80c3-compressed.prg 80c4-compressed.prg

.INTERMEDIATE: charset.bin
charset.bin: charset.o charset.cfg
	ld65 -C charset.cfg $< -o $@

charset%.bin: charset%.o charset.cfg
	ld65 -C charset.cfg $< -o $@

%-compressed.prg: %-uncompressed.prg
	exomizer sfx 51200 -q -n -o $@ $<

%-uncompressed.prg: %.bin
	(printf '\0\310'; cat $<) > $@

.PHONY: update-font-images
update-font-images: charset.bin charset2.bin charset3.bin charset4.bin mkfontimg.py
	python mkfontimg.py -l charset.bin  img/t1.png
	python mkfontimg.py    charset.bin  img/g1.png
	python mkfontimg.py -l charset2.bin img/t2.png
	python mkfontimg.py    charset2.bin img/g2.png
	python mkfontimg.py -l charset3.bin img/t3.png
	python mkfontimg.py    charset3.bin img/g3.png
	python mkfontimg.py -l charset4.bin img/t4.png
	python mkfontimg.py    charset4.bin img/g4.png

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
