lex AST.l
yacc -d Inorder.y
gcc lex.yy.c y.tab.c -ll -ly
./a.out < Test.c
./a.out < Test1.c
