def iclass(c):
    return int(c << 26)

def generateJ(target):
    return iclass(2) | ((int(target) >> 2) & 0x03ffffff)

def generateJal(target):
    return iclass(3) | ((int(target) >> 2) & 0x03ffffff)

def instBytes(res):
    return res.to_bytes(4)
