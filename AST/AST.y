%{
	#include"Node.h"
	#include<string.h>
	#include<stdio.h>
	#include<stdlib.h>
	#include<ctype.h>

	int number;
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
	int yyerror();
	int yylex();
	void label();
	char depth[ 2056 ];
	int di=0;
	FILE *f2;
	
	/*typedef struct node {
		char value[50];
		struct node *left;
		struct node *right;
	} Node ;*/

	typedef struct node Node;
	void printTree(Node *root);
	void Inorder(Node *root);
	Node* make_node(char *, Node *, Node *);
//	Node *inorder_root;
%}
%union
{
	struct node *nodeptr;
	char var[10];
}

%token MAIN 
%token <var> NUM VAR RELOP  TYPE
%token WHILE IF 
%type <nodeptr> ASSIGNMENT DESCT  BLOCK 
%type <nodeptr> EXPR RELEXPR VARLIST STATEMENT CODE PROGRAM Main
%left '-' '+'
%left '*' '/'

%%
Main : TYPE MAIN '(' ')' '{' PROGRAM '}'  { $$ = make_node("PROGRAM", make_node($1, NULL, NULL), $6);  printTree($$);};

PROGRAM : CODE	{ $$ = $1;}
	;

BLOCK : '{' CODE '}'  {  $$ = $2; };
	;

CODE : 	  BLOCK { $$ = $1;}
	| STATEMENT CODE { $$ = make_node("STATEMENT", $1, $2);}
	| STATEMENT	{ $$ = $1; }
	;

STATEMENT : DESCT ';' { $$ = $1; }
	  | ASSIGNMENT ';' { $$ = $1; }
	  | WHILE '(' RELEXPR ')' BLOCK  { $$ = make_node("while", $3, $5);}
	  | IF '(' RELEXPR ')' BLOCK { $$ = make_node("if", $3, $5);}	
	  ;
DESCT : TYPE VARLIST	{ $$ = make_node("Type", make_node($1, NULL, NULL), $2);}
;
VARLIST : VAR ',' VARLIST { $$ = make_node("VARLIST",make_node($1, NULL, NULL), $3); }
	 | VAR { $$ = make_node($1, NULL, NULL); }
	;

ASSIGNMENT: VAR '=' EXPR {  $$ = make_node("=", make_node($1, NULL, NULL), $3);};

EXPR 	: EXPR '+' EXPR { $$ = make_node("+", $1, $3);}
     	| EXPR '-' EXPR { $$ = make_node("+", $1, $3);}			
     	| EXPR '*' EXPR { $$ = make_node("+", $1, $3);}
     	| EXPR '/' EXPR { $$ = make_node("*", $1, $3);}
     	| VAR	{ $$ = make_node($1, NULL, NULL); }
     	| NUM	{ $$ = make_node($1, NULL, NULL); }
     	;

RELEXPR:    VAR RELOP RELEXPR { $$ = make_node($2, make_node($1, NULL, NULL), $3); printf("%s\n", $3->value);}
	   | NUM RELOP RELEXPR { $$ = make_node($2, make_node($1, NULL, NULL), $3);}
	   | VAR { $$ = make_node($1, NULL, NULL); }
     	   | NUM { $$ = make_node($1, NULL, NULL); }
	   ;

%%

Node *make_node(char *value, Node *left, Node *right) {
	Node *new_node = malloc(sizeof(Node));
	strcpy(new_node->value, value);	
	new_node -> left = left;
	new_node -> right = right;
	return new_node;
}

void Inorder(Node *root){
	if (root == NULL)
		return;
	printTree(root->left);
	printf("%s ", root->value);
	printTree(root->right);
}

void Push( char c )
	{
	    depth[ di++ ] = ' ';
	    depth[ di++ ] = c;
	    depth[ di++ ] = ' ';
	    depth[ di++ ] = ' ';
	    depth[ di ] = 0;
	}
	 
	void Pop( )
	{
	    depth[ di -= 4 ] = 0;
	}
	 
	void printTree( struct node* tree )
	{	
		
		if(tree==NULL)
		{
			return ;
		}
	    
	    fprintf(f2, "(%s)\n", tree->value );
	 
	    if ( tree->left )
	    {
	        fprintf(f2, "%s \\__", depth );
	        Push( '|' );
	        	printTree( tree->left );
	        Pop( );
	 		if(tree->right)
	 		{
		        fprintf(f2, "%s \\__", depth );
		        Push( ' ' );
		        printTree( tree->right );
		        Pop( );
	        }
	    }
		
	}

int yyerror()
{
	printf("\n Error on line no:%d\n",LineNo);
	return 1;
}

int main(int argc,char *argv[])
{
	int i;
	f2 = fopen("AST.txt", "w");	
	if(!(yyparse())) {
		printf("\n Tree printed in Inorder traversal");
	}
	printf("\n\n");
	return 0;
}
