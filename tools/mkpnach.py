#!/bin/env python3

import sys

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

from instutils import Mips
from pnach import PnachWriter


REGION_TABLE = {
        # Regions.
        'pal': {
            'pnachCRC': 'FDA1CBF6',
            'entryHookAddress': 0x0014d58c,
            'func1HookAddress': 0x00187aac,
            'func2HookAddress': 0x001c481c,
            'func3HookAddress': 0x001404e4,
            'func4HookAddress': 0x00187d20,
        },
        'usa': {
            'pnachCRC': '07652DD9',
            'entryHookAddress': 0x0014d564,
            'func1HookAddress': 0x00187b24,
            'func2HookAddress': 0x001c45b4,
            'func3HookAddress': 0x001404cc,
            'func4HookAddress': 0x00187d98,
        }
}

# Table of name -> int address pair. Populated by populateAddressTable().
addrTable : dict[str, int] = {}

def findSymbolInElf(elfObject: ELFFile, symbolName: str):
    section = elfObject.get_section_by_name('.symtab')
    if not section:
        raise ValueError('ELF does not have a symbol table? WTF')
    if not isinstance(section, SymbolTableSection):
        raise ValueError('not a symbol table section? What?')

    for symbol in section.iter_symbols():
        if symbol.name == symbolName:
            return symbol['st_value']


def populateAddressTable(elfFileName: str):
    print(f'Loading code blob ELF file \'{elfFileName}\'')
    # Addresses which we care about here
    caredAddresses = [
        'meosCamText', # start of .text code section
        'meosFreecamEntryHook',
        'meosFreecamFunc1',
        'meosFreecamFunc2',
        'meosFreecamFunc3',
        'meosFreecamFunc4'
    ]
    with open(elfFileName, 'rb') as elfFile:
        elfObject = ELFFile(elfFile)
        for symName in caredAddresses:
            addrTable[symName] = findSymbolInElf(elfObject, symName)
            print(f'Located {symName} @ {addrTable[symName]:08x}')

# Reads a file in 4 byte (EE word) yielded chunks
def readWordChunks(file):
    while True:
        data = file.read(4)
        if not data:
            break
        yield data

REGION_NAME = sys.argv[1]
MATCHING = sys.argv[2]

try:
    region = REGION_TABLE[REGION_NAME]
except:
    print(f'Region {REGION_NAME} is not implemented yet')
    exit(1)

# gather the correct blob filename based on whether or not it's matching'
if MATCHING == 'y':
    BLOB_FILENAME = 'meoscam_code'
else:
    BLOB_FILENAME = 'meoscam_code_nonmatching'

# Populate the address table from the ELF.
populateAddressTable(f'obj/{REGION_NAME}/{BLOB_FILENAME}_linked.elf')

# Write the pnach out.
with PnachWriter.file(f'{region['pnachCRC']}.freecam.pnach') as pnachWriter:
        with pnachWriter.cheat('Freecam','Meos for original freecam, modeco80 USA/Disasm', 'Press L3 to enable freecam. See original Meos pnach for other controls.') as cheat:
            # Poke in the hooks to the game code

            # vtable entry hook
            cheat.setAddress(region['entryHookAddress'])
            cheat.word(Mips.jal(addrTable['meosFreecamEntryHook']))

            cheat.setAddress(region['func1HookAddress'])
            cheat.word(Mips.jal(addrTable['meosFreecamFunc1']))
            cheat.word(Mips.nop()) # delay slot nop

            cheat.setAddress(region['func2HookAddress'])
            cheat.word(Mips.j(addrTable['meosFreecamFunc2']))

            cheat.setAddress(region['func3HookAddress'])
            cheat.word(Mips.jal(addrTable['meosFreecamFunc3']))

            cheat.setAddress(region['func4HookAddress'])
            cheat.word(Mips.jal(addrTable['meosFreecamFunc4']))

            # For our last step, poke in the code blob.
            cheat.setAddress(addrTable['meosCamText'])
            with open(f'obj/{REGION_NAME}/{BLOB_FILENAME}.bin', 'rb') as codeFile:
                for word in readWordChunks(codeFile):
                        cheat.word(word)

print('pnach file written successfully')
