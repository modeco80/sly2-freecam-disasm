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
    def write_word(self, bytestring, reverse=True):
       self._pnach_writer._write_word(bytestring, reverse)

    def write_word_freeze(self, bytestring, reverse=True):
       self._pnach_writer._write_word_freeze(bytestring, reverse)



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
    def _write_word_mode(self, mode, bytestring, reverse=False):
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

    def _write_word(self, bytestring, reverse=False):
       self._write_word_mode('0', bytestring, reverse)

    def _write_word_freeze(self, bytestring, reverse=False):
       self._write_word_mode('1', bytestring, reverse)
