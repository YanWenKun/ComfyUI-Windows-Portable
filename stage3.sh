#!/bin/bash
set -eux

ls -lahF

du -hd1

# LZMA2 is ~75% faster than LZMA, but consumes significant more RAM
# Use 2140000000b as volume size just because GitHub think 2147483648b is "larger than 2GB"
"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma2 -mx=7 -mfb=64 -md=32m -ms=on -mf=BCJ2 -v2140000000b ComfyUI_Windows_portable_cu121.7z ComfyUI_Windows_portable

ls -lahF
