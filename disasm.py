#!/bin/env python3

import rabbitizer

with open("meoscam_paired.csv") as inCsv:
	with open("meoscam.asm", "w") as outBin:
		for line in inCsv:
			line=line.strip()
			values=line.split(',')
			address=values[0]
			hexWord=values[1]
			print(f"{address} = {hexWord}")
