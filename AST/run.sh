lex AST.l
yacc -d AST.y
gcc lex.yy.c y.tab.c -ll -ly
./a.out < Test1.c
