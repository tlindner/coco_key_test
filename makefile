# KEYTEST Makefile (pattern-rule version)

LWASM = lwasm
DECB  = decb

DSK   = KEYTEST.DSK

BIN   = kt-f.bin kt-b.bin kt-cc3.bin
ROM   = kt-f.rom
LST   = kt-f.lst kt-b.lst kt-cc3.lst kt-f-rom.lst

.PHONY: all clean dsk

all: $(DSK)

# ----------------------------
# Assembly rules (pattern)
# ----------------------------

kt-%.bin: kt-%.asm
	$(LWASM) $< --decb -o$@ --list=$(basename $@).lst

kt-f.rom: kt-f-rom.asm
	$(LWASM) $< --raw -o$@ --list=kt-f-rom.lst

# ----------------------------
# Disk image
# ----------------------------

$(DSK): $(BIN) $(ROM) kt.bas
	$(DECB) dskini $(DSK)
	$(DECB) copy -t kt.bas $(DSK),KT.BAS
	$(DECB) copy -2b kt-f.bin $(DSK),KT-F.BIN
	$(DECB) copy -2b kt-b.bin $(DSK),KT-B.BIN
	$(DECB) copy -2b kt-cc3.bin $(DSK),KT-CC3.BIN
	$(DECB) copy -2b kt-f.rom $(DSK),KT-F.ROM

# ----------------------------
# Cleanup
# ----------------------------

clean:
	rm -f $(BIN) $(ROM) $(LST) $(DSK)