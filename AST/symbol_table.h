#include<stdio.h>

struct symbol_table {
	char variableName[10];
	int value;
	int scope_count;
	char scopeType[10];
}symbol_table[100];
