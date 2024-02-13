ASSEMBLER = z80-unknown-coff-as
LINKER = z80-unknown-coff-ld
OBJCOPY = z80-unknown-coff-objcopy

ASFLAGS = -march=z80
LDFLAGS =  

SRC_ASM := $(wildcard *.asm)
OBJ_FILES := $(patsubst %.asm,%.out,$(SRC_ASM))

all: md5check

rom.bin: $(OBJ_FILES) rom.ld
	$(LINKER) $(LDFLAGS) -T rom.ld -Map=rom.map $(OBJ_FILES) -o $@

%.out: %.asm
	$(ASSEMBLER) $(ASFLAGS) $< -o $@ > $<.lst

.PHONY: clean md5check
clean:
	rm -f *.hex *.out *.bin *.map *.lst

md5check: rom.bin
	md5sum -c md5.txt