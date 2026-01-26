# Sly 2 Freecam Disassembly

This is a matching disassembly of Meos' freecam for Sly 2 (PAL). The ASM source in this repository builds to a fully matching version of the code inside the original pnach for PAL, but:

- is fully labeled, meaning it doesn't depend on hardcoded jump offsets
- gathers its externals from labels defined in separate linker script files

This allows for a lot of fun things, including porting it to other regions. A (work-in-progress) USA port is actually provided in this repository!

# Building

You need:

- A Linux system.
- Basic build tools (make).
- decompals binutils. It is available [here](https://github.com/decompals/binutils-mips-ps2-decompals/releases).
- OPTIONAL: python.

Place the decompals binutils binaries into a new `binutils/` folder.

Run `make`. Optionally, to build the USA code blob and pnach, run `make REGION=usa`.
