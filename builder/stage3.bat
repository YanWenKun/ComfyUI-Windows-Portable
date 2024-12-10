@REM Notes on 7zip compression:

@REM Use 2140000000b as volume size just because GitHub think 2147483648b is "larger than 2GB".

@REM LZMA2 is ~75% faster than LZMA, but consumes significant more RAM.
@REM The param "-mx=5 -mfb=32 -md=16m" is equivalent to "Normal Compression" in 7-Zip GUI.

@REM Out of curiosity, I made a comparison:

@REM "-mx=7 -mfb=64 -md=32m"
@REM Add new data to archive: 9181 folders, 61097 files, 10816801395 bytes (11 GiB)
@REM Archive size: 4610629660 bytes (4398 MiB)
@REM Ratio: 0.426
@REM Compression Time: 1050s

@REM "-mx=5 -mfb=32 -md=16m"
@REM Add new data to archive: 9238 folders, 61469 files, 10962874842 bytes (11 GiB)
@REM Archive size: 4707714040 bytes (4490 MiB)
@REM Ratio: 0.429
@REM Compression Time: 840s

@REM "-mx=3 -mfb=32 -md=4m"
@REM Add new data to archive: 9238 folders, 61469 files, 10962875003 bytes (11 GiB)
@REM Archive size: 5027350682 bytes (4795 MiB)
@REM Ratio: 0.459
@REM Compression Time: 565s

@REM So I choose the "Normal Compression". Also, its decompression time is ideal.

"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma2 -mx=5 -mfb=32 -md=16m -ms=on -mf=BCJ2 -v2140000000b ComfyUI_Windows_portable_cu124.7z ComfyUI_Windows_portable

dir
