def iclass(c):
    return int(c << 26)

# MIPS instruction encoding helpers.
class Instructions:
    @staticmethod
    def nop():
        return b'\x00\x00\x00\x00'
    # encodes a `j xxx`
    @staticmethod
    def j(target):
        return int(iclass(3) | ((int(target) >> 2) & 0x03ffffff)).to_bytes(4)
    # encodes a `jal xxx`
    @staticmethod
    def jal(target):
        return int(iclass(3) | ((int(target) >> 2) & 0x03ffffff)).to_bytes(4)
