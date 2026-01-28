#!/bin/env python3

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

__all__ = [ 'ElfSymbolizer' ]

# Class which manages grabbing the symbol table, as a slightly
# higher-level wrapper over the pyelftools library.
class ElfSymbolizer:
    _elfFile: ELFFile
    _symbolTableSection: SymbolTableSection

    def __init__(self, elfFileName: str):
        self._elfFile = ELFFile(open(elfFileName, 'rb'))
        self._symbolTableSection = self._elfFile.get_section_by_name('.symtab')
        if not self._symbolTableSection:
            raise ValueError('ELF does not have a symbol table? WTF')
        if not isinstance(self._symbolTableSection, SymbolTableSection):
            raise ValueError('not a symbol table section? What?')

    def symbol(self, symbolName: str) -> int:
        # FIXME: better algorithm
        for symbol in self._symbolTableSection.iter_symbols():
            if symbol.name == symbolName:
                return symbol['st_value']
