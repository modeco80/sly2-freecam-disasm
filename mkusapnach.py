#!/bin/env python3

import binascii


def splitByCount(s, n):
    return [s[i:i+n] for i in range(0, len(s), n)]

# Reads a file in 4 byte (EE Word) chunks
def read_as_word_chunks(file):
    while True:
        data = file.read(4)
        if not data:
            break
        yield data

# A pnach cheat
class _PnachCheat:
    def __init__(self, pnach_writer):
       self._pnach_writer = pnach_writer

    # writes a pnach patch to write the given word into memory
    # if the provided bytestring is not large enough, it is padded with 0 bytes
    def write_word(self, bytestring):
       self._pnach_writer._write_word(bytestring)

    def write_word_raw(self, string):
        self._pnach_writer.write_word_raw(string)


# A basic writer for pnach files
class PnachWriter:
    def __init__(self, file):
       self._file = file
       self._base_address = 0x0
       self._addr = 0x0

    # Set the base address
    def set_base_address(self, base_address):
       self._base_address = base_address
       self._addr = base_address

    # Begins cheat. Returns a object which can be used to add
    # patches to the cheat
    def begin_cheat(self, section_name, author, comment):
       self._file.write(f'[{section_name}]\n')
       if author:
           self._file.write(f'author={author}\n')
       if comment:
           self._file.write(f'comment={comment}\n')
       return _PnachCheat(self)


    def write_comment(self, comment):
       self._file.write(f'//{comment}\n')

    # writes a pnach patch to write the given word into memory
    # if the provided bytestring is not large enough, it is padded with 0 bytes
    def _write_word(self, bytestring):
       pad_length = len(bytestring) % 4
       put_bytes = bytes(reversed(bytestring))
       if pad_length:
            put_bytes += bytes(4 - len(bytestring))
       byte_string = binascii.hexlify(put_bytes).decode('utf-8')
       self._file.write(f'patch=0,EE,20{self._addr:06x},extended,{byte_string}\n')
       self._addr += 0x4

    # unsafe as hell
    def write_word_raw(self, string):
        groups = splitByCount(string, 2)
        assert(len(groups) == 4)
        hexWord = f'{groups[3]}{groups[2]}{groups[1]}{groups[0]}'
        self._file.write(f'patch=0,EE,20{self._addr:06x},extended,{hexWord}\n')
        self._addr += 0x4

with open('07652DD9.freecam.pnach', 'w') as pnachFileRaw:
        pnachWriter = PnachWriter(pnachFileRaw)
        cheat = pnachWriter.begin_cheat('Freecam','Meos for original freecam, modeco80 USA/Disasm', 'Press L3 to enable freecam. See original PAL pnach for controls.')
        # poke in the hooks

        # entry hook
        pnachWriter.set_base_address(0x0014d564)
        cheat.write_word_raw('12FD030C') # jal 0xff44c

        # fun1 hook
        pnachWriter.set_base_address(0x00187b24)
        cheat.write_word_raw('66FD030C')

        # fun2 hook
        pnachWriter.set_base_address(0x001c481c)
        cheat.write_word_raw('6FFD030C')

        # fun3 hook
        pnachWriter.set_base_address(0x001404cc)
        cheat.write_word_raw('7BFD030C')

        # fun4 hook
        pnachWriter.set_base_address(0x00187d98)
        cheat.write_word_raw('84FD030C')

        # poke in the code blob
        pnachWriter.set_base_address(0x000ff000)
        with open('meoscam_code_nonmatching.bin', 'rb') as codeFile:
             for word in read_as_word_chunks(codeFile):
                    cheat.write_word(word)

print('the dance has been done.')
