# Pnach writing helpers

import binascii

def splitByCount(s, n):
    return [s[i:i+n] for i in range(0, len(s), n)]

# A pnach cheat
class _PnachCheat:
    def __init__(self, pnach_writer):
       self._pnach_writer = pnach_writer

    # writes a pnach patch to write the given word into memory
    # if the provided bytestring is not large enough, it is padded with 0 bytes
    def write_word(self, bytestring, mode='0', reverse=True):
       self._pnach_writer._write_word(bytestring, mode, reverse)

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
    def _write_word(self, bytestring, mode='0', reverse=True):
       pad_length = len(bytestring) % 4

       if reverse:
        put_bytes = bytes(reversed(bytestring))
       else:
        put_bytes = bytes(bytestring)

       if pad_length:
            put_bytes += bytes(4 - len(bytestring))
       byte_string = binascii.hexlify(put_bytes).decode('utf-8')
       self._file.write(f'patch={mode},EE,20{self._addr:06x},extended,{byte_string}\n')
       self._addr += 0x4

    # unsafe as hell
    def write_word_raw(self, string, mode='0'):
        groups = splitByCount(string, 2)
        assert(len(groups) == 4)
        hexWord = f'{groups[3]}{groups[2]}{groups[1]}{groups[0]}'
        self._file.write(f'patch={mode},EE,20{self._addr:06x},extended,{hexWord}\n')
        self._addr += 0x4
