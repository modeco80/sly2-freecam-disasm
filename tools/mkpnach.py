#!/bin/env python3

import sys

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





# Reads a file in 4 byte (EE Word) chunks
def read_as_word_chunks(file):
    while True:
        data = file.read(4)
        if not data:
            break
        yield data

REGION_NAME = sys.argv[1]
try:
    region = REGION_TABLE[REGION_NAME]
except:
    print(f'Region {REGION_NAME} is not implemented yet')
    exit(1)

print(region)

# gather the correct blob filename
if REGION_NAME == 'pal':
    BLOB_FILENAME = 'meoscam_code'
else:
    BLOB_FILENAME = 'meoscam_code_nonmatching'

# TODO: before we do this, dump the elf's base address
# and symbols we care about, and use them.

# Write the pnach out.
with open(f'{region['pnachCRC']}.freecam.pnach', 'w') as pnachFileRaw:
        pnachWriter = PnachWriter(pnachFileRaw)
        cheat = pnachWriter.begin_cheat('Freecam','Meos for original freecam, modeco80 USA/Disasm', 'Press L3 to enable freecam. See original Meos pnach for other controls.')
        # poke in the hooks

        # entry hook
        pnachWriter.set_base_address(region['entryHookAddress'])
        cheat.write_word(instBytes(generateJal(0xff44c)), '0', False)

        # fun1 hook
        pnachWriter.set_base_address(region['func1HookAddress'])
        cheat.write_word(instBytes(generateJal(0xff59c)), '0', False)
        # delay slot nop
        cheat.write_word_raw('00000000')

        # fun2 hook
        pnachWriter.set_base_address(region['func2HookAddress'])
        cheat.write_word(instBytes(generateJ(0xff5c0)), '0', False)

        pnachWriter.set_base_address(region['func3HookAddress'])
        cheat.write_word(instBytes(generateJal(0xff5f0)), '0', False)

        pnachWriter.set_base_address(region['func4HookAddress'])
        cheat.write_word(instBytes(generateJal(0xff614)), '0', False)

        # poke in the code blob
        pnachWriter.set_base_address(0x000ff000)
        with open(f'obj/{REGION_NAME}/{BLOB_FILENAME}.bin', 'rb') as codeFile:
             for word in read_as_word_chunks(codeFile):
                    cheat.write_word(word, '0')

print('pnach file written successfully')
