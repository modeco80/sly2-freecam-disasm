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
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code$(BINARY_SUFFIX).elf check
	./tools/mkpnach/mkpnach.py $(REGION) $(MATCHING)
else
all: $(OBJDIR)/ $(OBJDIR)/meoscam_code$(BINARY_SUFFIX).elf
	./tools/mkpnach/mkpnach.py $(REGION) $(MATCHING)
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
	./tools/mkpnach/sum.py
endif

$(OBJDIR)/:
	mkdir -p $@

$(OBJDIR)/meoscam.ld: src/meoscam.ld
	sed 's|REGIONLD|regions/$(REGION).ld|' $< | sed 's|OBJDIR|$(OBJDIR)|' - > $@

$(OBJDIR)/meoscam_code$(BINARY_SUFFIX).elf: $(OBJDIR)/meoscam.ld $(OBJECTS)
	$(LD) -T $(OBJDIR)/meoscam.ld -EL $(OBJECTS) -o $@

$(OBJDIR)/%.o: src/%.asm
	cpp $< | $(AS) -EL -G0 -g -march=r5900 - -o $@
