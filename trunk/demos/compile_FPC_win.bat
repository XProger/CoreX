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

fpc CoreX_Demos.dpr -Mobjfpc -Rintel -B -Nu -O3 -Sh -Si -Ur -Xt -Xs -XX -XS -CX -Sv -viewnh -FCtmp -FUtmp -Fu..\ -o..\CoreX_Demos.exe
pause