OUTPUT_FORMAT(binary)
SECTIONS {
	. = 0xfeffb;

	.data 0x0feffb: {
		*(.data)
		*(.data.*)
    	*(.gnu.linkonce.d*)
	}


	.text 0xff000 : {
		*(.text)
		*(.text.*)
    	*(.gnu.linkonce.t*)
	}

	/DISCARD/ : {
		*(.reginfo)
		*(.MIPS.abiflags)


		*(.rodata)
		*(.rodata.*)
		*(.gnu.linkonce.r*)

		*(.rdata)
		*(.lit8)
		*(.lit4)

		*(.sdata)
		*(.sbss)
		*(.scommon)
		*(.bss)
	}

	/* Sly functions/variables */

	MatrixCopy = 0x14F5C8;

	_end = .;
}
