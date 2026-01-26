# place decompals binutils in binutils/ to build it
AS := binutils/mips-ps2-decompals-as
LD := binutils/mips-ps2-decompals-ld
OBJCOPY := binutils/mips-ps2-decompals-objcopy

ifeq ($(MATCHING),)
MATCHING:=y
endif

REGION=pal

ifneq ($(REGION),pal)
MATCHING := n
endif

ifeq ($(MATCHING),y)
all: meoscam_code.bin
	$(MAKE) check
else
all: meoscam_code_nonmatching.bin
	./mkusapnach.py
endif

matrix:
	$(MAKE)
	$(MAKE) REGION=usa

ifeq ($(MATCHING),y)
clean:
	rm meoscam_code.o meoscam_code.bin meoscam_code_linked.bin
else

clean:
	rm meoscam_code_nonmatching.o meoscam_code_nonmatching.bin meoscam_code_nonmatching_linked.bin
endif
# check sha256sum matches, for PAL only
check:
	echo "b5c2ae13fdfc88fdf83ebb6acb83802cc3e9a5f680396cd39bda378068f7ec00  meoscam_code.bin" | sha256sum -c -

ifeq ($(MATCHING),y)
meoscam_code.bin: meoscam_code.o
	sed 's|REGIONLD|$(REGION).ld|' meoscam.ld > /tmp/lds_$(REGION).ld
	$(LD) -T /tmp/lds_$(REGION).ld $< -o meoscam_code_linked.bin
	dd if=meoscam_code_linked.bin of=$@ bs=1 skip=5 status=none
	rm /tmp/lds_$(REGION).ld

meoscam_code.o: meoscam.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
else
meoscam_code_nonmatching.bin: meoscam_code_nonmatching.o
	sed 's|REGIONLD|$(REGION).ld|' meoscam.ld > /tmp/lds_$(REGION).ld
	$(LD) -T /tmp/lds_$(REGION).ld $< -o meoscam_code_nonmatching_linked.bin
	dd if=meoscam_code_nonmatching_linked.bin of=$@ bs=1 skip=5 status=none
	rm /tmp/lds_$(REGION).ld

meoscam_code_nonmatching.o: meoscam.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
endif
