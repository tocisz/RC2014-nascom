ASSEMBLER = z80-unknown-coff-as
LINKER = z80-unknown-coff-ld
OBJCOPY = z80-unknown-coff-objcopy

ASFLAGS = -a -march=z80
LDFLAGS =  

LD_FILES := $(wildcard *.ld)
SRC_ASM := $(wildcard *.asm)
OBJ_FILES := $(patsubst %.asm,%.out,$(SRC_ASM))

all: md5check ram.hex

ram.hex: system.out
	$(OBJCOPY) -O ihex -j.ram $< $@

rom.bin: system.out
	$(OBJCOPY) -O binary -j.rom $< $@

system.out: $(OBJ_FILES) $(LD_FILES)
	$(LINKER) $(LDFLAGS) -T system.ld -Map=system.map $(OBJ_FILES) -o $@

%.out: %.asm
	$(ASSEMBLER) $(ASFLAGS) $< -o $@ > $<.lst

.PHONY: clean md5check
clean:
	rm -f *.hex *.out *.bin *.map *.lst

md5check: rom.bin
	md5sum -c md5.txt