#!/bin/env python3

# Pnach writing helpers.

__all__ = [ 'PnachWriter' ]

# A pnach cheat.
# NOTES:
# - short and word (and their freeze variants) take an `reverse` boolean,
#   this essentially allows you to flip the endian if needed. by default
#   these are true, but if you want the value to stay normal, you can do
#   `,reverse=False` to opt out of this behavior for a single patch line
#   if it's easier to you, or just bytes(reversed()) your input beforehand.
class PnachCheat:
    def __init__(self, pnach_writer):
        self._pnach_writer = pnach_writer

    def byte(self, inByteString: bytes):
        self._pnach_writer._writeByte('EE', inByteString)

    def byteFreeze(self, inByteString: bytes):
        self._pnach_writer._writeByteFreeze('EE', inByteString)

    def short(self, inByteString: bytes, reverse=True):
        self._pnach_writer._writeShort('EE', inByteString, reverse)

    def shortFreeze(self, inByteString: bytes, reverse=True):
        self._pnach_writer._writeShortFreeze('EE', inByteString, reverse)

    def word(self, inByteString: bytes, reverse=True):
        self._pnach_writer._writeWord('EE', inByteString, reverse)

    def wordFreeze(self, inByteString: bytes, reverse=True):
        self._pnach_writer._writeWordFreeze('EE', inByteString, reverse)

    def setAddress(self, address: int):
        self._pnach_writer._setAddress(address)

    # writes a comment. if you want the comment to have an initial space,
    # the string you pass here must have it.
    def comment(self, com: str):
        self._pnach_writer._writeComment(com)

    # Context manager functions
    def __enter__(self):
        self._old_address = self._pnach_writer._getAddress()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self._pnach_writer._setAddress(self._old_address)

# Returns the E-type for a particular word size.
def getETypeForSize(size: int) -> str:
    match size:
        case 1:
            return '0'
        case 2:
            return '1'
        case 4:
            return '2'
        case _:
            raise ValueError(f'Invalid size {size}')

# Asserts a valid pnach CPU type.
def assertValidCpu(cpu: str):
    match cpu:
        case 'EE':
            pass
        case 'IOP':
            pass
        case _:
            raise ValueError(f'Invalid Pnach CPU {cpu}.')

# A basic writer for pnach files. Supports usage as a context manager,
# so it's quite easy to use and code shouldn't get too ratty.
class PnachWriter:
    _addr: int

    # helper method which returns a pnach writer with the file open already
    @staticmethod
    def file(filename: str):
        return PnachWriter(open(filename, 'w'))

    def __init__(self, file):
       self._file = file
       # TODO: We should probably store per-cpu addresses, instead of
       # just storing one master address. For now it's whatever, since
       # the APIs don't really support IOP patch lines yet...
       self._addr = 0x0

    def _getAddress(self) -> int:
        return self._addr

    def _setAddress(self, address: int):
       self._addr = address

    def close(self):
        self._file.close()
        self._addr = 0x0

    # Begins cheat. Returns a object which can be used to add
    # patche lines to the cheat
    def cheat(self, sectionName: str, author: str, comment: str) -> PnachCheat:
       self._file.write(f'[{sectionName}]\n')
       if author:
           self._file.write(f'author={author}\n')
       if comment:
           self._file.write(f'comment={comment}\n')
       return PnachCheat(self)


    def _writeComment(self, comment: str):
       self._file.write(f'//{comment}\n')

    # Writes an E-type patch line for the given bytes.
    def _writePnachLine(self, mode: str, cpu: str, size: int, inByteString: bytes, reverse=False):
        # Do some checks on the input. CPU type, whether the byte string will actually make sense..
        assertValidCpu(cpu)
        if len(inByteString) < size:
            raise ValueError('Invalid byte array for this size')

        # Currently this code can't "fall back" to an legacy type code,
        # for later, this might be nice, since I believe the legacy
        # code types can place anywhere. For now this sanity check should work.
        if (self._addr & 0xf0000000) != 0:
            raise ValueError(f'Address 0x{self._addr:08x} cannot be written to with an E-type code.')

        putBytes = inByteString[:size]
        if reverse:
            putBytes = bytearray(reversed(putBytes))
        else:
            putBytes = bytearray(putBytes)

        # Add zero-padding.
        if (len(putBytes) % 4) != 0:
            putBytes[:0] = bytearray(4 - len(putBytes))

        byteString = putBytes.hex()
        codeType = getETypeForSize(size)

        self._file.write(f'patch={mode},{cpu},{codeType}{self._addr:07x},extended,{byteString}\n')
        self._addr += size


    def _writeBytePatchLine(self, mode: str, cpu: str, inByteString: bytes):
        return self._writePnachLine(mode, cpu, 1, inByteString, reverse=True)

    def _writeShortPatchLine(self, mode: str, cpu: str, inByteString: bytes, reverse):
        return self._writePnachLine(mode, cpu, 2, inByteString, reverse)

    def _writeWordPatchLine(self, mode: str, cpu: str, inByteString: bytes, reverse):
        return self._writePnachLine(mode, cpu, 4, inByteString, reverse)

    def _writeByte(self, cpu: str, inByteString: bytes):
       self._writeBytePatchLine('0', cpu, inByteString)

    def _writeByte_freeze(self, cpu: str, inByteString: bytes):
       self._writeBytePatchLine('1', cpu, inByteString)

    def _writeShort(self, cpu: str, inByteString: bytes, reverse):
       self._writeShortPatchLine('0', cpu, inByteString, reverse)

    def _writeShort_freeze(self, cpu: str, inByteString: bytes, reverse):
       self._writeShortPatchLine('1', cpu, inByteString, reverse)

    def _writeWord(self, cpu: str, inByteString: bytes, reverse):
       self._writeWordPatchLine('0', cpu, inByteString, reverse)

    def _writeWordFreeze(self, cpu: str, inByteString: bytes, reverse):
       self._writeWordPatchLine('1', cpu, inByteString, reverse)

    # Context manager functions
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()
