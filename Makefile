ASSEMBLER = z80-unknown-coff-as
LINKER = z80-unknown-coff-ld
OBJCOPY = z80-unknown-coff-objcopy

ASFLAGS = -a -march=z80
LDFLAGS =

LD_FILES := $(wildcard *.ld)
SYSTEM_OBJ := bas32k.o const.o int32k.o page0.o

all: md5check rom.bin hello.hex tests.hex

rom.bin: system.out
	$(OBJCOPY) -O binary -j.rom $< $@

hello.hex: hello.out
	$(OBJCOPY) -O ihex -j.ram $< $@

tests.hex: tests.out
	$(OBJCOPY) -O ihex -j.ram $< $@

system.out: $(SYSTEM_OBJ) $(LD_FILES)
	$(LINKER) $(LDFLAGS) -T system.ld -Map=system.map $(SYSTEM_OBJ) -o $@

hello.out: hello.o $(SYSTEM_OBJ) $(LD_FILES)
	$(LINKER) $(LDFLAGS) -T system.ld -Map=hello.map $< $(SYSTEM_OBJ) -o $@

tests.out: tests.o $(SYSTEM_OBJ) $(LD_FILES)
	$(LINKER) $(LDFLAGS) -T system.ld -Map=tests.map $< $(SYSTEM_OBJ) -o $@

tests.o: tests.asm tested_original.asm tested_new.asm

%.o: %.asm
	$(ASSEMBLER) $(ASFLAGS) $< -o $@ > $<.lst

.PHONY: clean md5check
clean:
	rm -f *.hex *.out *.o *.bin *.map *.lst

md5check: rom.bin
	md5sum -c md5.txt