#!/usr/bin/env python3
import argparse
import pathlib
import os
import sys

import logging

parser = argparse.ArgumentParser()
parser.add_argument("path", type=pathlib.Path)
parser.add_argument("--out_dir", type=pathlib.Path, default="./out")
args = parser.parse_args()

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger()
logger.info(f"Parsing file {args.path}")

header = ""
raw_data = []
with open(args.path, "r") as f:
    name = f.readline().strip()
    if name != "Land-Ocean: Global Means":
        logger.critical("File appears to be incorrect format!")
        sys.exit(1)

    header = f.readline()
    raw_data = f.readlines()


if not args.out_dir.is_dir():
    os.makedirs(args.out_dir)

h = header.split(",")
new_header = [h[0]]
for m in h[1:14]:
    new_header.append("{:>5}".format(m))

## Trim and reformat data
new_data = []
for row in raw_data:
    r = [x.strip() for x in row.split(",")]
    year = r[0]
    temps = r[1:14]

    if "***" in temps:
        logger.info(f"Skipping year with incomplete data {year}...")
        continue

    new_row = [year]
    for t in temps:
        new_row.append("{:-5.2f}".format(float(t)))

    new_data.append(",".join(new_row))


new_path = args.out_dir / f"{args.path.stem}_trimmed{args.path.suffix}"
with open(new_path, "w") as f:
    f.write(",".join(new_header))
    f.write("\n")
    f.write("\n".join(new_data))

## Calculate temperature deltas
delta_data = []
for i in range(len(new_data) - 1):
    prev = [x.strip() for x in new_data[i].split(",")]
    next = [x.strip() for x in new_data[i + 1].split(",")]

    new_row = [next[0]]
    for i in range(1, 14):
        d = float(next[i]) - float(prev[i])
        new_row.append("{:-5.2f}".format(d))

    delta_data.append(",".join(new_row))


new_path = args.out_dir / f"{args.path.stem}_deltas{args.path.suffix}"
with open(new_path, "w") as f:
    f.write(",".join(new_header))
    f.write("\n")
    f.write("\n".join(delta_data))
