# place decompals binutils in binutils/ to build it
AS := binutils/mips-ps2-decompals-as
LD := binutils/mips-ps2-decompals-ld
OBJCOPY := binutils/mips-ps2-decompals-objcopy

ifeq ($(MATCHING),)
MATCHING:=y
endif

REGION=pal

# If the default of matching is set, and the region isn't PAL,
# force matching off. Otherwise, don't touch it.
ifeq ($(MATCHING),y)
ifneq ($(REGION),pal)
MATCHING := n
endif
endif

ifeq ($(MATCHING),n)
BINARY_SUFFIX := _nonmatching
endif

OBJDIR := obj/$(REGION)

# objects (in the correct order)
OBJECTS := \
	$(OBJDIR)/main.o \
	$(OBJDIR)/hooks.o \
	$(OBJDIR)/vars.o

ifeq ($(MATCHING),y)
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code$(BINARY_SUFFIX).bin check
else
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code$(BINARY_SUFFIX).bin
ifeq ($(REGION),usa)
	./mkusapnach.py
endif
endif

matrix:
	$(MAKE)
	$(MAKE) REGION=usa

matrixclean:
	$(MAKE) clean
	$(MAKE) REGION=usa clean

clean:
	rm -rf $(OBJDIR)

# check sha256sum of the blob matches a clean extracted blob, for PAL only
ifeq ($(MATCHING),y)
check:
	echo "b5c2ae13fdfc88fdf83ebb6acb83802cc3e9a5f680396cd39bda378068f7ec00  obj/pal/meoscam_code.bin" | sha256sum -c -
endif

$(OBJDIR)/:
	mkdir -p $@

$(OBJDIR)/meoscam.ld: src/meoscam.ld
	sed 's|REGIONLD|regions/$(REGION).ld|' $< | sed 's|OBJDIR|$(OBJDIR)|' - > $@

$(OBJDIR)/meoscam_code$(BINARY_SUFFIX).bin: $(OBJDIR)/meoscam_code$(BINARY_SUFFIX)_linked.elf
	$(OBJCOPY) -O binary $< $(OBJDIR)/meoscam_code$(BINARY_SUFFIX)_linked.bin
	dd if=$(OBJDIR)/meoscam_code$(BINARY_SUFFIX)_linked.bin of=$@ bs=1 skip=5 status=none


$(OBJDIR)/meoscam_code$(BINARY_SUFFIX)_linked.elf: $(OBJDIR)/meoscam.ld $(OBJECTS)
	$(LD) -T $(OBJDIR)/meoscam.ld -EL $(OBJECTS) -o $@

$(OBJDIR)/%.o: src/%.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
