# Porting Guide

Want to port the freecam to another region of Sly 2 that it hasn't been ported to yet? Well here you go!

This guide is split into various steps.

# Linker script

We need to create a region-specific ld linker script file for the new region.

In `regions/` make a ld file with some name (For example, Japan could be something like `jpn`) and copy the contents of an existing one. 

You'll need to find each of those addresses, either with existing documentation (a lot of addresses and functions are there, some aren't), or for ones that aren't, you'll have to pattern search the elf by picking a semi-unique instruction or data from another supported region's elf, searching for it in the region you're adding support for and explore around to find the equivalent address for that region/version.

After doing this step, it's possible to build the blob, but it won't be useful yet because we can't turn it into a pnach at this stage.

# mkpnach augmentation

We now need to add support to mkpnach for our new region

The `tools/mkpnach/regionconsts.py` file controls supported regions. It has a table mapping region name to a set of important values like the Pnach crc, and hook addresses.

You'll need to fill them in for your new region, using the same process used for the linker script.

After doing this, you can now run `make REGION=[new region]` to build a pnach for your region. If it doesn't fully work, tweak it until it does. Once you're done and it works, you can PR it into the repo!
