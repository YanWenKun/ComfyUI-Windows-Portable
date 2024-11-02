#!/bin/bash
set -eux

ls -lahF

du -hd1

# Notes on 7zip compression:

# Use 2140000000b as volume size just because GitHub think 2147483648b is "larger than 2GB".

# LZMA2 is ~75% faster than LZMA, but consumes significant more RAM.
# The param "-mx=5 -mfb=32 -md=16m" is equivalent to "Normal Compression" in 7Zip GUI.

# Out of curiosity, I made a comparison:

# "-mx=5 -mfb=32 -md=16m"
# Add new data to archive: 9181 folders, 61097 files, 10816792329 bytes (11 GiB)
# Archive size: 4681965078 bytes (4466 MiB)
# Compression Time: 866s

# "-mx=7 -mfb=64 -md=32m"
# Add new data to archive: 9181 folders, 61097 files, 10816801395 bytes (11 GiB)
# Archive size: 4610629660 bytes (4398 MiB)
# Compression Time: 1050s

# The file size difference is small.
# So I choose the "Normal Compression", not for faster compression time, but for faster decompression time.

"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma2 -mx=3 -mfb=32 -md=4m -ms=on -mf=BCJ2 -v2140000000b ComfyUI_Windows_portable_cu124.7z ComfyUI_Windows_portable

ls -lahF
