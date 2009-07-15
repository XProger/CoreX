cd H:\Projects\CoreX\demos

del /s *.~*
del /s *.dcu
del /s *.dsk
del /s *.obj
del /s *.dsm
del /s *.rsm
del /s *.rar
del /s *.ddp
del /s *.o
del /s *.a
del /s *.ppu
del /s *.bak
del /s *.tmp

"H:\Program Files\CodeGear\RAD Studio\6.0\bin\dcc32.exe" SpriteAnim.dpr -B -E..\ -U..\
pause