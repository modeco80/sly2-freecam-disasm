# Sly 2 Freecam Disassembly

This is a matching disassembly of Meos' freecam for Sly 2 (PAL). 

The ASM source in this repository builds to a fully matching version of the code inside the original pnach for PAL, but:

- is fully labeled, meaning it doesn't depend on any hardcoded jump offsets (making it shiftable)
- gathers its externals from labels defined in separate linker script files (game variables and functions are referred to by name rather than address)

This allows for a lot of fun things, including porting it to other regions. 

A USA port is actually provided in this repository!

Additionally, [a guide on porting this repository to new regions](./docs/PORTING.md) is available.

# Building

You need:

- A Linux system.
- Basic build tools (`build-essential` on Debian-likes, `base-devel` on Arch).
- decompals binutils. It is available [here](https://github.com/decompals/binutils-mips-ps2-decompals/releases).
- Python (w/ pipenv, `pipenv` on Debian-likes, `python-pipenv` on Arch)

Clone this repository.

Place the decompals binutils binaries into a new `binutils/` folder at the root of the repository.

Run `pipenv install`. Once this has finished, run `pipenv shell`.

Run `make` to build the PAL blob and pnach.

To build the USA code blob and pnach, run `make REGION=usa`. Other regions are built in the same way,
but replace `usa` with.. something else. (you can also use `pal` to build PAL, but that's the default)
