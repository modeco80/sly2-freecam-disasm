#!/bin/bash
# Using the UNIX paste command, combine the address and byte data together
# into one "CSV" file. We don't write the header.
#echo "Address,Word" > meoscam_paired.csv
paste -d, res/meoscam.addrs res/meoscam.bytes > meoscam_paired.csv
