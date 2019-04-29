%{
	#include<string.h>
	#include<stdio.h>
	#include<stdlib.h>
	#include<ctype.h>
	#include "symbol_table.h"
	int number;
	struct quad
	{
		char op[5];
		char arg1[10];
		char arg2[10];
		char result[10];
		int scope;
	}QUAD[30];
	struct stack 
	{
		int items[100];
		int top;
	}stk;
	int Index=0;
	int tIndex=0; 
	int StNo;
	int Ind; 
	int tInd;
	int checkIndex = 0;
	extern int LineNo; 
	char* toString(int number);
	void AddQuadruple(char op[5],char arg1[10],char arg2[10],char result[10]);
	int getValue(int , int , char*);
	int checkSymbolTable(char *);
	void printQuadRuples();
	int yyerror();
	int yylex();
	void label();
	extern int scopeCount;
	int globalIndex = 0;
	int labelCount = 0;
	int symbol_table_index = 0;
	char scopeType[10];

%}
%union
{
	char var[10];
}


%token <var> NUM VAR RELOP MAIN TYPE
%token WHILE IF 
%type <var> EXPR ASSIGNMENT RELEXPR VARLIST
%left '-' '+'
%left '*' '/'

%%
Main : TYPE MAIN { strcpy(scopeType, "main");}'(' ')' '{' PROGRAM '}' ;

PROGRAM : CODE
	;

BLOCK : '{' CODE '}' { printQuadRuples();} ;
	;

CODE : 	  BLOCK 
	| STATEMENT CODE
	| STATEMENT
	;

STATEMENT : DESCT ';'
	  | ASSIGNMENT ';'
	  | WHILE { strcpy(scopeType, "while");} '(' RELEXPR ')' BLOCK  
	  | IF { strcpy(scopeType, "if");}'(' RELEXPR ')' BLOCK 
	  ;
DESCT : TYPE VARLIST
;

;
VARLIST : VAR ',' VARLIST	
	| VAR
	;

ASSIGNMENT: VAR '=' EXPR{						
			strcpy(QUAD[Index].op,"=");
			strcpy(QUAD[Index].arg1,$3);
			strcpy(QUAD[Index].arg2,"");
			strcpy(QUAD[Index].result,$1);
			QUAD[Index].scope = scopeCount;
			checkIndex = checkSymbolTable($3);			
			//printf("%d ", scopeCount);			
			if(checkIndex != -1) {
				symbol_table[globalIndex].value = symbol_table[checkIndex].value;
				symbol_table[globalIndex].scope_count = scopeCount;
				strcpy(symbol_table[globalIndex].scopeType, scopeType);
				strcpy(symbol_table[globalIndex++].variableName, $1);   				
			} else {
				checkIndex = checkSymbolTable($1);
				if (checkIndex != -1) {
					symbol_table[checkIndex].value = atoi($3);
				} else {
					symbol_table[globalIndex].value = atoi($3);
					symbol_table[globalIndex].scope_count = scopeCount;
					strcpy(symbol_table[globalIndex].scopeType, scopeType);
					strcpy(symbol_table[globalIndex++].variableName, $1);
				}
					
			}
			strcpy($$,QUAD[Index++].result);
			
			
			}
			;
EXPR : EXPR '+' EXPR { //printf("%s %s %s\n", $1, $3, $$);
			if(isdigit($1[0]) && isdigit($3[0])) {
				strcpy($$, toString(atoi($1) + atoi($3))); AddQuadruple("+",$1,$3,$$);
		    	}else{ 
			checkIndex = checkSymbolTable($3);			
			if(checkIndex != -1) {
				strcpy($$, toString(atoi($1) + symbol_table[checkIndex].value)); 
				AddQuadruple("+",$1,$3,$$);			
			} else {
				checkIndex = checkSymbolTable($1);
				strcpy($$, toString(symbol_table[checkIndex].value + atoi($3))); 
				AddQuadruple("+",$1,$3,$$);		
			}
			}				
			
		     } 
			
			
     | EXPR '-' EXPR { if(isdigit($1[0]) && isdigit($3[0])) {
				strcpy($$, toString(atoi($1) - atoi($3))); AddQuadruple("-",$1,$3,$$);
		    	}else{ 
			checkIndex = checkSymbolTable($3);			
			if(checkIndex != -1) {
				strcpy($$, toString(atoi($1) - symbol_table[checkIndex].value)); 
				AddQuadruple("-",$1,$3,$$);			
			} else {
				checkIndex = checkSymbolTable($1);
				strcpy($$, toString(symbol_table[checkIndex].value - atoi($3))); 
				AddQuadruple("-",$1,$3,$$);		
			}
			}}
     | EXPR '*' EXPR { if(isdigit($1[0]) && isdigit($3[0])) {
				strcpy($$, toString(atoi($1) * atoi($3))); AddQuadruple("*",$1,$3,$$);
		    	}else{ 
			checkIndex = checkSymbolTable($3);			
			if(checkIndex != -1) {
				strcpy($$, toString(atoi($1) * symbol_table[checkIndex].value)); 
				AddQuadruple("*",$1,$3,$$);			
			} else {
				checkIndex = checkSymbolTable($1);
				strcpy($$, toString(symbol_table[checkIndex].value * atoi($3))); 
				AddQuadruple("*",$1,$3,$$);		
			}
			}}
     | EXPR '/' EXPR { if(isdigit($1[0]) && isdigit($3[0])) {
				strcpy($$, toString(atoi($1) / atoi($3))); AddQuadruple("/",$1,$3,$$);
		    	}else{ 
			checkIndex = checkSymbolTable($3);			
			if(checkIndex != -1) {
				strcpy($$, toString(atoi($1) / symbol_table[checkIndex].value)); 
				AddQuadruple("/",$1,$3,$$);			
			} else {
				checkIndex = checkSymbolTable($1);
				strcpy($$, toString(symbol_table[checkIndex].value / atoi($3))); 
				AddQuadruple("/",$1,$3,$$);		
			}
			}}
     | '-' EXPR {AddQuadruple("UMIN",$2,"",$$);}
     
     | VAR	
     | NUM
     ;

RELEXPR:    VAR RELOP RELEXPR { 	if (isdigit($3[0])) {
					strcpy($$, toString(getValue(symbol_table[atoi($1)].value, atoi($3), $2))); 
				} else {
					strcpy($$, toString(getValue(symbol_table[atoi($1)].value, symbol_table[atoi($3)].value, $2))); 
				}
				AddQuadruple($2,$1,$3,$$);
			   }
	   | NUM RELOP RELEXPR { 	if (isdigit($3[0])) {
					strcpy($$, toString(getValue(atoi($1), atoi($3), $2))); 
					} else {
					strcpy($$, toString(getValue(atoi($1), symbol_table[atoi($3)].value, $2))); 
					}
				AddQuadruple($2,$1,$3,$$);
			     }
	   | VAR
	   | NUM
	   ;

%%

void label() {
	//printf("L%d: ",labelCount);
	labelCount += 1;
}
int getValue(int value1, int value2, char* operator){
	if(strcmp(operator, ">") == 0) 
		return value1 > value2;
	else if(strcmp(operator, "<") == 0) 
		return value1 < value2;
	else if(strcmp(operator, ">=") == 0) 
		return value1 >= value2;
	else if(strcmp(operator, "<=") == 0)
		return value1 <= value2;
	else if(strcmp(operator, "==") == 0)
		return value1 == value2;		
	else 
		return value1 != value2;	
}

char* toString(int number) {

	if (number == 1) {
		char *str = (char *)malloc(sizeof(char)*(2));
		str[0] = '1';
		str[1] = '\0';
		return str;
	}
	if (number == 0) {
		char *str = (char *)malloc(sizeof(char)*(2));
		str[0] = '0';
		str[1] = '\0';
		return str;
	}
	int negativeCheck = 0;
	char *str;
	int j;
	if(number < 0) {
		number = abs(number);
		negativeCheck = 1;
	}
	int temp = number;
	int numberOfDigit = 0;
	while(temp > 0) {
		temp = temp / 10;
		numberOfDigit += 1;
	}
	if (negativeCheck == 1) {
		str = (char *)malloc(sizeof(char)*(numberOfDigit + 2));
		str[0] = '-';
		j = numberOfDigit; 
	} else {
		str = (char *)malloc(sizeof(char)*(numberOfDigit + 1));
		j = numberOfDigit - 1;
	}
	while(number > 0) {
		temp = number % 10;
		str[j] = temp + '0';
		j -= 1;
		number = number / 10;
	}
	if (negativeCheck == 1) {
		str[numberOfDigit + 1] = '\0';
	} else {
		str[numberOfDigit] = '\0';
	}
	return str;
	
}


int checkSymbolTable(char *arg1) {
	for (int i = 0; i < 26; i++) {
		if (strcmp(arg1, symbol_table[i].variableName) == 0) {			
			return i;
		}
	}
	return -1;
	
}
void AddQuadruple(char op[5],char arg1[10],char arg2[10],char result[10])
{	 
	strcpy(QUAD[Index].op,op);
	strcpy(QUAD[Index].arg1,arg1);
	strcpy(QUAD[Index].arg2,arg2);
	sprintf(QUAD[Index].result,"t%d",tIndex++); 
	strcpy(symbol_table[globalIndex].variableName, QUAD[Index].result);
	symbol_table[globalIndex].value = atoi(result);
	strcpy(symbol_table[globalIndex++].scopeType, scopeType);
	symbol_table[globalIndex++].scope_count = scopeCount;
	strcpy(result,QUAD[Index++].result);
	QUAD[Index].scope = scopeCount;
}
int yyerror()
{
	printf("\n Error on line no:%d\n",LineNo);
	return 1;
}

void printQuadRuples() {
	
}

int main(int argc,char *argv[])
{
	int i;
	if(!(yyparse())) {
	printf("\t\t\t\t Symbol Table \t\t\t\t\n");
	printf("\n\t%s\t|\t%s\t|\t%s\t|\t%s\t|\t%s","Varibale Name","Value","Scope Number", "Scope Type","Variable Type");
	printf("\n\t-----------------------------------------------------------------------------------------------");	
	for (int i = 0; i < 10; i++) {
				
				
				if (strcmp(symbol_table[i].variableName,"") != 0)
						printf("\n\t\t%s\t|\t%d\t|\t%d\t\t|\t%s\t\t|\t\t%s\t", symbol_table[i].variableName, symbol_table[i].value, 
						symbol_table[i].scope_count, symbol_table[i].scopeType, "int");
	}
	printf("\n\n");	
	printf("\t\t\t\t Quadruples \t\t\t\t\n");
	printf("\n\t%s\t|\t%s\t|\t%s\t|\t%s\t|\t%s\t","pos","op","arg1","arg2","result");
	printf("\n\t------------------------------------------------------------------------");
	for(i=0;i<Index;i++)
	{
		printf("\n\t%d\t|\t%s\t|\t%s\t|\t%s\t|\t%s\t", i,QUAD[i].op, QUAD[i].arg1,QUAD[i].arg2,QUAD[i].result);
	}
	printf("\n\n\n\n");
	int scope[10] = {-1};
	int scopeIndex = 0;
	int gotoLabel = 0;
	for(i=0;i<Index;i++)
	{	
		if (gotoLabel == 1) {
			//scopeIndex[scopeIndex] = QUAD[i].scope;			
			printf("L%d:\n",gotoLabel);
			gotoLabel = 0; 		
		}
		if(strcmp(QUAD[i].op,"=") == 0) {	
			if (i == Index - 1 && strcmp(scopeType, "while") == 0)	
				printf("%s %s %s %s %s goto L%d \n",QUAD[i].result, "=", QUAD[i].arg1, QUAD[i].op, QUAD[i].arg2, gotoLabel);
			else 
				printf("%s %s %s %s\n",QUAD[i].result, QUAD[i].op, QUAD[i].arg1,QUAD[i].arg2);
			//printf("%s %s %s %s\n",QUAD[i].result, QUAD[i].op, QUAD[i].arg1,QUAD[i].arg2);
		} else if (strcmp(QUAD[i].op,">") == 0 || strcmp(QUAD[i].op,"!=") == 0) {
			gotoLabel = 1;
			printf("L%d: %s %s %s %s %s goto L%d \n",QUAD[i].scope,QUAD[i].result, "=", QUAD[i].arg1, QUAD[i].op, QUAD[i].arg2, QUAD[i].scope+1);
		} else {
			printf("%s %s %s %s %s\n",QUAD[i].result, "=", QUAD[i].arg1, QUAD[i].op, QUAD[i].arg2);	
		}
	}
	printf("\n\n");
	}
	return 0;
}
