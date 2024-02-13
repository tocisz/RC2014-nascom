ASSEMBLER = z80-unknown-coff-as
LINKER = z80-unknown-coff-ld
OBJCOPY = z80-unknown-coff-objcopy

ASFLAGS = -a
LDFLAGS =  

SRC_ASM := $(wildcard *.asm)
OBJ_FILES := $(patsubst %.asm,%.out,$(SRC_ASM))

all: rom.bin

rom.bin: $(OBJ_FILES) rom.ld
	$(LINKER) $(LDFLAGS) -T rom.ld -Map=rom.map $(OBJ_FILES) -o $@

%.out: %.asm
	$(ASSEMBLER) $(ASFLAGS) $< -o $@ > $<.lst

clean:
	rm -f *.hex *.out *.bin *.map *.lst
