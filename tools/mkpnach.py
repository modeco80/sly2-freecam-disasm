#!/bin/env python3

import sys

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

from instutils import generateJ, generateJal, instBytes
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
addrTable = {}

def findSymbolInElf(elfObject: ELFFile, symbolName: str):
    section = elfObject.get_section_by_name('.symtab')
    if not section:
        raise ValueError('ELF doesnt have symbol table? WTF')
    if not isinstance(section, SymbolTableSection):
        raise ValueError('not a symbol table section? What?')

    for symbol in section.iter_symbols():
        if symbol.name == symbolName:
            return symbol['st_value']


def populateAddressTable(elfFileName):
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

# Reads a file in 4 byte (EE Word) chunks
def read_as_word_chunks(file):
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
with open(f'{region['pnachCRC']}.freecam.pnach', 'w') as pnachFileRaw:
        pnachWriter = PnachWriter(pnachFileRaw)
        cheat = pnachWriter.begin_cheat('Freecam','Meos for original freecam, modeco80 USA/Disasm', 'Press L3 to enable freecam. See original Meos pnach for other controls.')
        # poke in the hooks

        # entry hook
        pnachWriter.set_base_address(region['entryHookAddress'])
        cheat.write_word(instBytes(generateJal(addrTable['meosFreecamEntryHook'])), '0', False)

        # fun1 hook
        pnachWriter.set_base_address(region['func1HookAddress'])
        cheat.write_word(instBytes(generateJal(addrTable['meosFreecamFunc1'])), '0', False)
        # delay slot nop
        cheat.write_word_raw('00000000')

        # fun2 hook
        pnachWriter.set_base_address(region['func2HookAddress'])
        cheat.write_word(instBytes(generateJ(addrTable['meosFreecamFunc2'])), '0', False)

        pnachWriter.set_base_address(region['func3HookAddress'])
        cheat.write_word(instBytes(generateJal(addrTable['meosFreecamFunc3'])), '0', False)

        pnachWriter.set_base_address(region['func4HookAddress'])
        cheat.write_word(instBytes(generateJal(addrTable['meosFreecamFunc4'])), '0', False)

        # poke in the code blob
        pnachWriter.set_base_address(addrTable['meosCamText'])
        with open(f'obj/{REGION_NAME}/{BLOB_FILENAME}.bin', 'rb') as codeFile:
             for word in read_as_word_chunks(codeFile):
                    cheat.write_word(word, '0')

print('pnach file written successfully')
