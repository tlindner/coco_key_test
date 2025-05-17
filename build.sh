#!/bin/sh -x

lwasm kt-f.asm --decb -okt-f.bin --list=kt-f.lst
lwasm kt-b.asm --decb -okt-b.bin --list=kt-b.lst
lwasm kt-cc3.asm --decb -okt-cc3.bin --list=kt-cc3.lst
lwasm kt-f-rom.asm --raw -okt-f.rom --list=kt-f-rom.lst
decb dskini KEYTEST.DSK
decb copy -t kt.bas KEYTEST.DSK,KT.BAS
decb copy -2b kt-f.bin KEYTEST.DSK,KT-F.BIN
decb copy -2b kt-b.bin KEYTEST.DSK,KT-B.BIN
decb copy -2b kt-cc3.bin KEYTEST.DSK,KT-CC3.BIN
decb copy -2b kt-f.rom KEYTEST.DSK,KT-F.ROM
