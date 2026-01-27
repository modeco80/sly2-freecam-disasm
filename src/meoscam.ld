/* ld script for the freecam blob */
SECTIONS {
	/* This LD script is preprocessed before usage, and the
	   marker string will be replaced with a path to the given region. */
	INCLUDE REGIONLD

	. = meosCamData;

	.data meosCamData : {
		OBJDIR/vars.o(.data)
	}

	.text meosCamText : {
		OBJDIR/main.o(.text)
		OBJDIR/hooks.o(.text)
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

	_end = .;
}
