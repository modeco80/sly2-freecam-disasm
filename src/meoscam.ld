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

	/* This LD script is preprocessed before usage, and the
	   marker string will be replaced with a path to the given region. */
	INCLUDE REGIONLD

	_end = .;
}
