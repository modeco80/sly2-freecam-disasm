#!/bin/env python3

# Script for verifying that the .text (program code) section
# of a newly-built PAL blob matches SHA-256 hash of extracted
# blob from the original pnach.

import sys
import os
from hashlib import sha256

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from utils.elf import ElfWrapper

expectedCsum = 'b5c2ae13fdfc88fdf83ebb6acb83802cc3e9a5f680396cd39bda378068f7ec00'

def getSha256Hash(data):
    hasher = sha256()
    hasher.update(data)
    return hasher.hexdigest()

def main():
    elf = ElfWrapper(f'obj/pal/meoscam_code.elf')
    programCore = elf.getProgramCore()
    checksum = getSha256Hash(programCore)
    if checksum != expectedCsum:
        print(f'HASH OF CODE {checksum} DOESNT MATCH EXPECTED {expectedCsum}')
        sys.exit(1)
    sys.exit(0)

if __name__ == '__main__':
    main()

