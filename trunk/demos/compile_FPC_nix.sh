cd /home/xproger/Projects/CoreX/demos
rm tmp/*

exec fpc SpriteAnim.dpr -Mobjfpc -Rintel -B -Nu -O3 -Sh -Ur -Xs -XX -CX -viewnh -o../SpriteAnim.elf -Fu../ -FUtmp
