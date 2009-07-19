cd /home/xproger/Projects/CoreX/demos
rm tmp/*

exec fpc CoreX_Demos.dpr -Mobjfpc -Rintel -B -Nu -O3 -Sh -Ur -Xs -XX -CX -viewnh -FUtmp -Fu../ -o../CoreX_Demos.elf