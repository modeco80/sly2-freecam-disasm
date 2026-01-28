#!/bin/env python3

from typing import TypedDict

__all__ = ['Region', 'REGION_TABLE']

class Region(TypedDict):
    # The PNACH/game CRC.
    pnachCRC: str
    entryHookAddress: int
    func1HookAddress: int
    func2HookAddress: int
    func3HookAddress: int
    func4HookAddress: int

# Regions supported by mkpnach.
#
# These regions must be able to build the blob (see regions/*.ld)
# first before being added to this table.
REGION_TABLE : dict[str, Region] = {
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
