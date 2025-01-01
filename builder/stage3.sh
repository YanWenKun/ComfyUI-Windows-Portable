#!/bin/bash
set -eux

ls -lahF

du -hd2 ComfyUI_Windows_portable

du -hd1 ComfyUI_Windows_portable/ComfyUI/custom_nodes

du -h ComfyUI_Windows_portable/ComfyUI/models

# Notes on 7zip compression:

# Use 2140000000b as volume size just because GitHub think 2147483648b is "larger than 2GB".

# LZMA2 is ~75% faster than LZMA, but consumes significant more RAM.
# The param "-mx=5 -mfb=32 -md=16m" is equivalent to "Normal Compression" in 7-Zip GUI.

# Out of curiosity, I made a comparison:

# "-mx=7 -mfb=64 -md=32m"
# Add new data to archive: 9181 folders, 61097 files, 10816801395 bytes (11 GiB)
# Archive size: 4610629660 bytes (4398 MiB)
# Ratio: 0.426
# Compression Time: 1050s

# "-mx=5 -mfb=32 -md=16m"
# Add new data to archive: 9238 folders, 61469 files, 10962874842 bytes (11 GiB)
# Archive size: 4707714040 bytes (4490 MiB)
# Ratio: 0.429
# Compression Time: 840s

# "-mx=3 -mfb=32 -md=4m"
# Add new data to archive: 9238 folders, 61469 files, 10962875003 bytes (11 GiB)
# Archive size: 5027350682 bytes (4795 MiB)
# Ratio: 0.459
# Compression Time: 565s

# So I choose the "Normal Compression". Also, its decompression time is ideal.

"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma2 -mx=5 -mfb=32 -md=16m -ms=on -mf=BCJ2 -v2140000000b ComfyUI_Windows_portable_cu124.7z ComfyUI_Windows_portable

ls -lahF