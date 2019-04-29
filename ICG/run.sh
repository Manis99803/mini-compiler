lex ICG.l
yacc -d ICG.y
gcc lex.yy.c y.tab.c -ll -ly
./a.out < Test.c

