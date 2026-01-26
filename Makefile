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

OBJDIR := obj/$(REGION)

ifeq ($(MATCHING),y)
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code.bin check
else
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code_nonmatching.bin
	./mkusapnach.py
endif

matrix:
	$(MAKE)
	$(MAKE) REGION=usa

matrixclean:
	$(MAKE) clean
	$(MAKE) REGION=usa clean

clean:
	rm -rf $(OBJDIR)

# check sha256sum matches, for PAL only
check:
	echo "b5c2ae13fdfc88fdf83ebb6acb83802cc3e9a5f680396cd39bda378068f7ec00  obj/pal/meoscam_code.bin" | sha256sum -c -

$(OBJDIR)/:
	mkdir -p $@

ifeq ($(MATCHING),y)
$(OBJDIR)/meoscam_code.bin: $(OBJDIR)/meoscam_code.o
	sed 's|REGIONLD|regions/$(REGION).ld|' src/meoscam.ld > /tmp/lds_$(REGION).ld
	$(LD) -T /tmp/lds_$(REGION).ld $< -o $(OBJDIR)/meoscam_code_linked.bin
	dd if=$(OBJDIR)/meoscam_code_linked.bin of=$@ bs=1 skip=5 status=none
	rm /tmp/lds_$(REGION).ld

$(OBJDIR)/meoscam_code.o: src/meoscam.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
else
$(OBJDIR)/meoscam_code_nonmatching.bin: $(OBJDIR)/meoscam_code_nonmatching.o
	sed 's|REGIONLD|regions/$(REGION).ld|' src/meoscam.ld > /tmp/lds_$(REGION).ld
	$(LD) -T /tmp/lds_$(REGION).ld $< -o $(OBJDIR)/meoscam_code_nonmatching_linked.bin
	dd if=$(OBJDIR)/meoscam_code_nonmatching_linked.bin of=$@ bs=1 skip=5 status=none
	rm /tmp/lds_$(REGION).ld

$(OBJDIR)/meoscam_code_nonmatching.o: src/meoscam.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
endif
