#!/bin/env python3

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import Section, SymbolTableSection

__all__ = [ 'ElfWrapper' ]

# Class which manages ELF file reading, as a slightly
# higher-level wrapper over the pyelftools library.
class ElfWrapper:
    _elfFile: ELFFile
    _symbolTableSection: SymbolTableSection
    _textSection: Section

    def __init__(self, elfFileName: str):
        self._elfFile = ELFFile(open(elfFileName, 'rb'))
        self._symbolTableSection = self._elfFile.get_section_by_name('.symtab')
        self._textSection = self._elfFile.get_section_by_name('.text')
        if not self._symbolTableSection:
            raise ValueError('ELF does not have a symbol table? WTF')
        if not isinstance(self._symbolTableSection, SymbolTableSection):
            raise ValueError('not a symbol table section? What?')

    # Returns the address (st_value) of a symbol in the ELF.
    def symbol(self, symbolName: str) -> int:
        # FIXME: better algorithm
        for symbol in self._symbolTableSection.iter_symbols():
            if symbol.name == symbolName:
                return symbol['st_value']

    # Returns the program core data.
    def getProgramCore(self):
        return self._textSection.data()
