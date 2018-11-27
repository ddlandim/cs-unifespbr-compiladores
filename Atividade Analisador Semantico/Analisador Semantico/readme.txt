sudo flex cminus.l
sudo bison -d cminus.y
sudo gcc -c *.c
sudo gcc -o cminus *.o -ly -lfl
sudo ./cminus file.cminus
