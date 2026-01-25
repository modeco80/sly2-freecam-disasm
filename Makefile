
AS := binutils/mips-ps2-decompals-as
LD := binutils/mips-ps2-decompals-ld
OBJCOPY := binutils/mips-ps2-decompals-objcopy

all: meoscam_code.bin check

clean:
	rm meoscam_code.o meoscam_code.bin meoscam_code_linked.bin

check:
	echo "b5c2ae13fdfc88fdf83ebb6acb83802cc3e9a5f680396cd39bda378068f7ec00  meoscam_code.bin" | sha256sum -c -

#meoscam_code.bin: meoscam_code.elf
#	$(OBJCOPY) -O binary $< $@

meoscam_code.bin: meoscam_code.o
	$(LD) -T meoscam.ld $< -o meoscam_code_linked.bin
	dd if=meoscam_code_linked.bin of=$@ bs=1 skip=5


meoscam_code.o: meoscam.labels.asm
	$(AS) -EL -G0 -g -march=r5900 $< -o $@
