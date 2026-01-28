#!/bin/env python3

import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# modules we depend on
from utils.mips import Mips
from utils.pnach import PnachWriter
from utils.elf import ElfSymbolizer

# local modules
from regionconsts import REGION_TABLE

# Reads a file in 4 byte (EE word) yielded chunks
def readWordChunks(file):
    while True:
        data = file.read(4)
        if not data:
            break
        yield data

# The fun begins...
def main():
    REGION_NAME = sys.argv[1]
    MATCHING = sys.argv[2]

    try:
        region = REGION_TABLE[REGION_NAME]
    except:
        print(f'Region {REGION_NAME} is not implemented yet')
        exit(1)

    # gather the correct blob filename based on whether or not it's matching.
    if MATCHING == 'y':
        BLOB_FILENAME = 'meoscam_code'
    else:
        BLOB_FILENAME = 'meoscam_code_nonmatching'

    # Open the ELF file so we can get at symbols in it.
    elf = ElfSymbolizer(f'obj/{REGION_NAME}/{BLOB_FILENAME}_linked.elf')

    # Write the pnach out.

    pnachAuthor = 'Meos for original freecam, modeco80 initial disassembly.'
    pnachComment = 'Press L3 to enable freecam. See original Meos pnach for other controls.'

    with PnachWriter.file(f'{region['pnachCRC']}.freecam.pnach') as pnachWriter:
            with pnachWriter.cheat('Freecam', pnachAuthor, pnachComment) as cheat:
                cheat.comment(' For detailed contributor information to the disassembly,')
                cheat.comment(' see https://github.com/modeco80/sly2-freecam-disasm/graphs/contributors')

                # Helpers to clean up function hooks
                def jHook(hookAddress: int, targetAddress: int):
                    cheat.setAddress(hookAddress)
                    cheat.word(Mips.j(targetAddress))

                def jalHook(hookAddress: int, targetAddress: int, nopDelaySlot=False):
                    cheat.setAddress(hookAddress)
                    cheat.word(Mips.jal(targetAddress))
                    # If nopping the delay slot is requested, do so.
                    if nopDelaySlot:
                        cheat.word(Mips.nop())

                # Poke in the hooks to the game code. Use the ELF file's symbols to figure out
                # where each of these hooks are actually placed in the blob, so it isn't hardcoded here.
                jalHook(region['entryHookAddress'], elf.symbol('meosFreecamEntryHook'))
                jalHook(region['func1HookAddress'], elf.symbol('meosFreecamFunc1'), nopDelaySlot=True)
                jHook(region['func2HookAddress'], elf.symbol('meosFreecamFunc2'))
                jalHook(region['func3HookAddress'], elf.symbol('meosFreecamFunc3'))
                jalHook(region['func4HookAddress'], elf.symbol('meosFreecamFunc4'))

                # For our last step, poke in the code blob.
                cheat.setAddress(elf.symbol('meosCamText'))
                with open(f'obj/{REGION_NAME}/{BLOB_FILENAME}.bin', 'rb') as codeFile:
                    for word in readWordChunks(codeFile):
                            cheat.word(word)

    print('pnach file written successfully')

if __name__ == '__main__':
    main()
