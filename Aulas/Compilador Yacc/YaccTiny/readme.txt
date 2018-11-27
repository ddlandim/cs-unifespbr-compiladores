
flex tiny.l
$ bison -d tiny.y
$ gcc -c *.c
$ gcc -o tiny *.o -ly -lfl
