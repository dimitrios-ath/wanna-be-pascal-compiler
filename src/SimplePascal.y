%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/tree.h"

void yyerror(const char *s);
int yylex();
extern int yylineno;
node *root;

%}

%locations

%token 	T_PROGRAM T_CONST T_TYPE T_ARRAY T_SET T_OF T_RECORD T_VAR T_FORWARD T_FUNCTION T_PROCEDURE
		T_INTEGER T_REAL T_BOOLEAN T_CHAR T_BEGIN T_END T_IF T_THEN T_ELSE T_WHILE T_DO T_FOR 
		T_DOWNTO T_TO T_WITH T_READ T_WRITE ID ADDOP_ADD ADDOP_SUB OROP NOTOP INOP LPAREN RPAREN 
		SEMI DOT COMMA EQU COLON LBRACK RBRACK ASSIGN DOTDOT ICONST BCONST CCONST STRING
		MULDIVANDOP_MUL MULDIVANDOP_DIV MULDIVANDOP_DIV_E MULDIVANDOP_MOD MULDIVANDOP_AND
		RELOP_NE RELOP_LE RELOP_GE RELOP_LT RELOP_GT RCONST_REAL RCONST_INT RCONST_HEX RCONST_BIN

%nonassoc T_THEN
%nonassoc T_ELSE

%nonassoc INOP RELOP_NE RELOP_LE RELOP_GE RELOP_LT RELOP_GT EQU
%left	ADDOP_ADD ADDOP_SUB OROP
%left	MULDIVANDOP_MUL MULDIVANDOP_DIV MULDIVANDOP_DIV_E MULDIVANDOP_MOD MULDIVANDOP_AND
%nonassoc NOTOP
%left LPAREN RPAREN
%left LBRACK RBRACK
%left DOT

%union {
	unsigned int integer;
	double real;
	int string_slots;
	char *string;
	char *operator_str;
	char character;
	int boolean;
	struct node* node;
}

%type <node> program header declarations constdefs constant_defs expression constant typedefs type_defs 
			 type_def dims limit limits typename standard_type fields field identifiers vardefs variable_defs
			 subprograms subprogram sub_header formal_parameters parameter_list pass comp_statement statements
			 variable statement if_statement assignment expressions subprogram_call setexpression
			 elexpressions elexpression io_statement read_list read_item while_statement for_statement
			 iter_space with_statement write_list write_item

%%

program : 	header declarations subprograms comp_statement DOT { 
				// printf("program → header declarations subprograms comp statement DOT\n");
				root = (node *) malloc(sizeof(node));
				root->value = strdup("program");
				$$ = root;
				root->node1 = $1;
				root->node2 = $2;
				root->node3 = $3;
				root->node4 = $4;
				node *node_semi = (node *) malloc(sizeof(node));
				node_semi->value = strdup(".");
				$$->node5 = node_semi;
			}
		;

header	: 	T_PROGRAM ID SEMI { 
				// printf("header → T_PROGRAM ID SEMI\n");
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("header");
				$$ = newnode;
				node *node_program = (node *) malloc(sizeof(node));
				node_program->value = strdup("program");
				$$->node1 = node_program;
				node *node_id = (node *) malloc(sizeof(node));
				node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node2 = node_id;
				node *node_semi = (node *) malloc(sizeof(node));
				node_semi->value = strdup(";");
				$$->node3 = node_semi;
				remove_last_yytext_element();
			}
		;

declarations	:	constdefs typedefs vardefs { 
						// printf("declarations → constdefs typedefs vardefs\n");
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("declarations");
						$$ = newnode;
						newnode->node1 = $1;
						newnode->node2 = $2;
						newnode->node3 = $3;
					}
				;

constdefs	:	T_CONST constant_defs SEMI { 
					// printf("constdefs → T_CONST constant_defs SEMI\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constdefs");
					$$ = newnode;
					node *node_const = (node *) malloc(sizeof(node));
					node_const->value = strdup("const");
					$$->node1 = node_const;
					$$->node2 = $2;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node3 = node_semi;
				}
			|	{
					// printf("CONSTDEFS → ε\n");
					$$ = NULL;
				}
			;

constant_defs	:	constant_defs SEMI ID EQU expression { 
						// printf("constant_defs → constant_defs SEMI ID EQU expression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("constant_defs");
						$$ = newnode;
						$$->node1 = $1;
						node *node_semi = (node *) malloc(sizeof(node));
						node_semi->value = strdup(";");
						$$->node2 = node_semi;
						node *node_id = (node *) malloc(sizeof(node));
						node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
						$$->node3 = node_id;
						node *node_equ = (node *) malloc(sizeof(node));
						node_equ->value = strdup("=");
						$$->node4 = node_equ;
						$$->node5 = $5;
						remove_last_yytext_element();
					}
				| 	ID EQU expression {
						// printf("constant_defs → ID EQU expression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("constant_defs");
						$$ = newnode;
						node *node_id = (node *) malloc(sizeof(node));
						node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
						$$->node1 = node_id;
						node *node_equ = (node *) malloc(sizeof(node));
						node_equ->value = strdup("=");
						$$->node2 = node_equ;
						$$->node3 = $3;
						remove_last_yytext_element();
					}
				;

expression	:	expression RELOP_NE expression { 
					// printf("expression → expression RELOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_relop = (node *) malloc(sizeof(node));
					node_relop->value = strdup("<>");
					$$->node2 = node_relop;
					$$->node3 = $3;
				}
			| 	expression RELOP_GE expression { 
					// printf("expression → expression RELOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_relop = (node *) malloc(sizeof(node));
					node_relop->value = strdup(">=");
					$$->node2 = node_relop;
					$$->node3 = $3;
				}
			|	expression RELOP_LE expression { 
					// printf("expression → expression RELOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_relop = (node *) malloc(sizeof(node));
					node_relop->value = strdup("<=");
					$$->node2 = node_relop;
					$$->node3 = $3;
				}
			|	expression RELOP_LT expression { 
					// printf("expression → expression RELOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_relop = (node *) malloc(sizeof(node));
					node_relop->value = strdup("<");
					$$->node2 = node_relop;
					$$->node3 = $3;
				}
			|	expression RELOP_GT expression { 
					// printf("expression → expression RELOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_relop = (node *) malloc(sizeof(node));
					node_relop->value = strdup(">");
					$$->node2 = node_relop;
					$$->node3 = $3;
				}
			|	expression EQU expression { 
					// printf("expression → expression EQU expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_equ = (node *) malloc(sizeof(node));
					node_equ->value = strdup("=");
					$$->node2 = node_equ;
					$$->node3 = $3;
				}
			|	expression INOP expression { 
					// printf("expression → expression INOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_or = (node *) malloc(sizeof(node));
					node_or->value = strdup("in");
					$$->node2 = node_or;
					$$->node3 = $3;
				}
			|	expression OROP expression { 
					// printf("expression → expression OROP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_or = (node *) malloc(sizeof(node));
					node_or->value = strdup("or");
					$$->node2 = node_or;
					$$->node3 = $3;
				}
			|	expression ADDOP_ADD expression	{ 
					// printf("expression → expression ADDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_addop = (node *) malloc(sizeof(node));
					node_addop->value = strdup("+");
					$$->node2 = node_addop;
					$$->node3 = $3;
				}
			|	expression ADDOP_SUB expression	{ 
					// printf("expression → expression ADDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_addop = (node *) malloc(sizeof(node));
					node_addop->value = strdup("-");
					$$->node2 = node_addop;
					$$->node3 = $3;
				}
			|	expression MULDIVANDOP_MUL expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_muldivandop = (node *) malloc(sizeof(node));
					node_muldivandop->value = strdup("*");
					$$->node2 = node_muldivandop;
					$$->node3 = $3;
				}
			|	expression MULDIVANDOP_DIV expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_muldivandop = (node *) malloc(sizeof(node));
					node_muldivandop->value = strdup("/");
					$$->node2 = node_muldivandop;
					$$->node3 = $3;
				}
			|	expression MULDIVANDOP_DIV_E expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_muldivandop = (node *) malloc(sizeof(node));
					node_muldivandop->value = strdup("div");
					$$->node2 = node_muldivandop;
					$$->node3 = $3;
				}
			|	expression MULDIVANDOP_MOD expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_muldivandop = (node *) malloc(sizeof(node));
					node_muldivandop->value = strdup("mod");
					$$->node2 = node_muldivandop;
					$$->node3 = $3;
				}
			|	expression MULDIVANDOP_AND expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
					node *node_muldivandop = (node *) malloc(sizeof(node));
					node_muldivandop->value = strdup("and");
					$$->node2 = node_muldivandop;
					$$->node3 = $3;
				}
			|	ADDOP_ADD expression { 
					// printf("expression → ADDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					node *node_addop = (node *) malloc(sizeof(node));
					node_addop->value = strdup("+");
					$$->node1 = node_addop;
					$$->node2 = $2;
				}
			|	ADDOP_SUB expression { 
					// printf("expression → ADDOP expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					node *node_addop = (node *) malloc(sizeof(node));
					node_addop->value = strdup("-");
					$$->node1 = node_addop;
					$$->node2 = $2;
				}
			|	NOTOP expression { 
					// printf("expression → NOTOP expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					node *node_not = (node *) malloc(sizeof(node));
					node_not->value = strdup("not");
					$$->node1 = node_not;
					$$->node2 = $2;
				}
			|	variable { 
					// printf("expression → variable\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
				}
			|	ID LPAREN expressions RPAREN { 
					// printf("expression → ID LPAREN expressions RPAREN\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_id;
					node *node_lparen = (node *) malloc(sizeof(node));
					node_lparen->value = strdup("(");
					$$->node2 = node_lparen;
					$$->node3 = $3;
					node *node_rparen = (node *) malloc(sizeof(node));
					node_rparen->value = strdup(")");
					$$->node4 = node_rparen;
					remove_last_yytext_element();
				}
			|	constant { 
					// printf("expression → constant\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
				}
			|	LPAREN expression RPAREN { 
					// printf("expression → LPAREN expression RPAREN\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					node *node_lparen = (node *) malloc(sizeof(node));
					node_lparen->value = strdup("(");
					$$->node1 = node_lparen;
					$$->node2 = $2;
					node *node_rparen = (node *) malloc(sizeof(node));
					node_rparen->value = strdup(")");
					$$->node3 = node_rparen;
				}
			|	setexpression { 
					// printf("expression → setexpression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expression");
					$$ = newnode;
					$$->node1 = $1;
				}
			;	


variable	:	ID { 
					// printf("variable → ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("variable");
					$$ = newnode;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_id;
					remove_last_yytext_element();
				}
			|	variable DOT ID { 
					// printf("variable → variable DOT ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("variable");
					$$ = newnode;
					$$->node1 = $1;
					node *node_dot = (node *) malloc(sizeof(node));
					node_dot->value = strdup(".");
					$$->node2 = node_dot;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node3 = node_id;
					remove_last_yytext_element();
				}
			|	variable LBRACK expressions RBRACK { 
					// printf("variable → variable LBRACK expressions RBRACK\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("variable");
					$$ = newnode;
					$$->node1 = $1;
					node *node_lbrack = (node *) malloc(sizeof(node));
					node_lbrack->value = strdup("[");
					$$->node2 = node_lbrack;
					$$->node3 = $3;
					node *node_rbrack = (node *) malloc(sizeof(node));
					node_rbrack->value = strdup("]");
					$$->node4 = node_rbrack;
				}
			;

expressions	:	expressions COMMA expression { 
					// printf("expressions → expressions COMMA expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expressions");
					$$ = newnode;
					$$->node1 = $1; 
					node *node_comma = (node *) malloc(sizeof(node));
					node_comma->value = strdup(",");
					$$->node2 = node_comma;
					$$->node3 = $3;
				}
			|	expression { 
					// printf("expressions → expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("expressions");
					$$ = newnode;
					$$->node1 = $1;
				}
			;

constant 	:	ICONST { 
					// printf("constant → ICONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_iconst = (node *) malloc(sizeof(node));
					node_iconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_iconst;
					remove_last_yytext_element();
				}
			| 	RCONST_REAL { 
					// printf("constant → RCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_rconst = (node *) malloc(sizeof(node));
					node_rconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_rconst;
					remove_last_yytext_element();
				}
			| 	RCONST_INT { 
					// printf("constant → RCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_rconst = (node *) malloc(sizeof(node));
					node_rconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_rconst;
					remove_last_yytext_element();
				}
			| 	RCONST_HEX { 
					// printf("constant → RCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_rconst = (node *) malloc(sizeof(node));
					node_rconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_rconst;
					remove_last_yytext_element();
				}
			| 	RCONST_BIN { 
					// printf("constant → RCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_rconst = (node *) malloc(sizeof(node));
					node_rconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_rconst;
					remove_last_yytext_element();
				}
			| 	BCONST { 
					// printf("constant → BCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_bconst = (node *) malloc(sizeof(node));
					node_bconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_bconst;
					remove_last_yytext_element();
				}
			| 	CCONST { 
					// printf("constant → CCONST\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("constant");
					$$ = newnode;
					node *node_cconst = (node *) malloc(sizeof(node));
					node_cconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_cconst;
					remove_last_yytext_element();
				}
			;

setexpression	: 	LBRACK elexpressions RBRACK { 
						// printf("setexpression → LBRACK elexpressions RBRACK\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("setexpression");
						$$ = newnode;
						node *node_lbrack = (node *) malloc(sizeof(node));
						node_lbrack->value = strdup("[");
						$$->node1 = node_lbrack;
						$$->node2 = $2;
						node *node_rbrack = (node *) malloc(sizeof(node));
						node_rbrack->value = strdup("]");
						$$->node3 = node_rbrack;
					}
				| 	LBRACK RBRACK { 
						// printf("setexpression → LBRACK RBRACK\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("setexpression");
						$$ = newnode;
						node *node_lbrack = (node *) malloc(sizeof(node));
						node_lbrack->value = strdup("[");
						$$->node1 = node_lbrack;
						node *node_rbrack = (node *) malloc(sizeof(node));
						node_rbrack->value = strdup("]");
						$$->node2 = node_rbrack;
					}
				;

elexpressions	:	elexpressions COMMA elexpression { 
						// printf("elexpressions → elexpressions COMMA elexpression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("elexpressions");
						$$ = newnode;
						$$->node1 = $1;
						node *node_comma = (node *) malloc(sizeof(node));
						node_comma->value = strdup(",");
						$$->node2 = node_comma;
						$$->node3 = $3;
					}
				|	elexpression {
						// printf("elexpressions → elexpression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("elexpressions");
						$$ = newnode;
						$$->node1 = $1;
					}
				;

elexpression	:	expression DOTDOT expression { 
						// printf("elexpression → expression DOTDOT expression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("elexpression");
						$$ = newnode;
						$$->node1 = $1;
						node *node_dotdot = (node *) malloc(sizeof(node));
						node_dotdot->value = strdup("..");
						$$->node2 = node_dotdot;
						$$->node3 = $3;
					}
				|	expression { 
						// printf("elexpression → expression\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("elexpression");
						$$ = newnode;
						$$->node1 = $1;
					}
				;

typedefs	:	T_TYPE type_defs SEMI	{
					// printf("typedefs → T_TYPE type_defs SEMI\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("typedefs");
					$$ = newnode;
					node *node_type = (node *) malloc(sizeof(node));
					node_type->value = strdup("type");
					$$->node1 = node_type;
					$$->node2 = $2;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node3 = node_semi;
				}
			| 	{ 
					// printf("typedefs → ε\n"); 
					$$ = NULL;
				}
			;

type_defs	:	type_defs SEMI ID EQU type_def { 
					// printf("type_defs → type_defs SEMI ID EQU type_def\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_defs");
					$$ = newnode;
					$$->node1 = $1;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node2 = node_semi;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node3 = node_id;
					node *node_equ = (node *) malloc(sizeof(node));
					node_equ->value = strdup("=");
					$$->node4 = node_equ;
					$$->node5 = $5;
					remove_last_yytext_element();
				}
			| 	ID EQU type_def { 
					// printf("type_defs → ID EQU type_def\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_defs");
					$$ = newnode;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_id;
					node *node_equ = (node *) malloc(sizeof(node));
					node_equ->value = strdup("=");
					$$->node2 = node_equ;
					$$->node3 = $3;
					remove_last_yytext_element();
				}
			;

type_def	:	T_ARRAY LBRACK dims RBRACK T_OF typename { 
					// printf("type_def → T_ARRAY LBRACK dims RBRACK T_OF typename\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_def");
					$$ = newnode;
					node *node_array = (node *) malloc(sizeof(node));
					node_array->value = strdup("array");
					$$->node1 = node_array;
					node *node_lbrack = (node *) malloc(sizeof(node));
					node_lbrack->value = strdup("[");
					$$->node2 = node_lbrack;
					$$->node3 = $3;
					node *node_rbrack = (node *) malloc(sizeof(node));
					node_rbrack->value = strdup("]");
					$$->node4 = node_rbrack;
					node *node_of = (node *) malloc(sizeof(node));
					node_of->value = strdup("of");
					$$->node5 = node_of;
					$$->node6 = $6;
				}
			|	T_SET T_OF typename { 
					// printf("type_def → T_SET T_OF typename\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_def");
					$$ = newnode;
					node *node_set = (node *) malloc(sizeof(node));
					node_set->value = strdup("set");
					$$->node1 = node_set;
					node *node_of = (node *) malloc(sizeof(node));
					node_of->value = strdup("of");
					$$->node2 = node_of;
					$$->node3 = $3;
				}
			|	T_RECORD fields T_END { 
					// printf("type_def → T_RECORD fields T_END\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_def");
					$$ = newnode;
					node *node_record = (node *) malloc(sizeof(node));
					node_record->value = strdup("record");
					$$->node1 = node_record;
					$$->node2 = $2;
					node *node_end = (node *) malloc(sizeof(node));
					node_end->value = strdup("end");
					$$->node3 = node_end;
				}
			|	LPAREN identifiers RPAREN { 
					// printf("type_def → LPAREN identifiers RPAREN\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_def");
					$$ = newnode;
					node *node_lparen = (node *) malloc(sizeof(node));
					node_lparen->value = strdup("(");
					$$->node1 = node_lparen;
					$$->node2 = $2;
					node *node_rparen = (node *) malloc(sizeof(node));
					node_rparen->value = strdup(")");
					$$->node3 = node_rparen;
				}
			|	limit DOTDOT limit { 
					// printf("type_def → limit DOTDOT limit\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("type_def");
					$$ = newnode;
					$$->node1 = $1;
					node *node_dotdot = (node *) malloc(sizeof(node));
					node_dotdot->value = strdup("..");
					$$->node2 = node_dotdot;
					$$->node3 = $3;
				}
			;

dims	:	dims COMMA limits { 
				// printf("dims → dims COMMA limits\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("dims");
				$$ = newnode;
				$$->node1 = $1;
				node *node_comma = (node *) malloc(sizeof(node));
				node_comma->value = strdup(",");
				$$->node2 = node_comma;
				$$->node3 = $3;
			}
		| 	limits { 
				// printf("dims → limits\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("dims");
				$$ = newnode;
				$$->node1 = $1;
			}
		;

limits	:	limit DOTDOT limit { 
				// printf("limits → limit DOTDOT limit\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limits");
				$$ = newnode;
				$$->node1 = $1;
				node *node_dotdot = (node *) malloc(sizeof(node));
				node_dotdot->value = strdup("..");
				$$->node2 = node_dotdot;
				$$->node3 = $3;
			}
		|	ID { 
				// printf("limits → ID\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limits");
				$$ = newnode;
				node *node_id = (node *) malloc(sizeof(node));
				node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node1 = node_id;
				remove_last_yytext_element();
			}
		;

limit	:	ADDOP_ADD ICONST { 
				// printf("limit → ADDOP ICONST\n");
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode; 
				node *node_addop_add = (node *) malloc(sizeof(node));
				node_addop_add->value = strdup("+");
				$$->node1 = node_addop_add;
				node *node_iconst = (node *) malloc(sizeof(node));
				node_iconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node2 = node_iconst;
				remove_last_yytext_element();
			}
		|	ADDOP_SUB ICONST { 
				// printf("limit → ADDOP ICONST\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_addop_sub = (node *) malloc(sizeof(node));
				node_addop_sub->value = strdup("-");
				$$->node1 = node_addop_sub;
				node *node_iconst = (node *) malloc(sizeof(node));
				node_iconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node2 = node_iconst;
				remove_last_yytext_element();
			}
		| 	ADDOP_ADD ID { 
				// printf("limit → ADDOP ID\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_addop_add = (node *) malloc(sizeof(node));
				node_addop_add->value = strdup("+");
				$$->node1 = node_addop_add;
				node *node_id = (node *) malloc(sizeof(node));
				node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node2 = node_id;
				remove_last_yytext_element();
			}
		| 	ADDOP_SUB ID { 
				// printf("limit → ADDOP ID\n");
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_addop_sub = (node *) malloc(sizeof(node));
				node_addop_sub->value = strdup("-");
				$$->node1 = node_addop_sub;
				node *node_id = (node *) malloc(sizeof(node));
				node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node2 = node_id;
				remove_last_yytext_element();
			}
		| 	ICONST { 
				// printf("limit → ICONST\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_iconst = (node *) malloc(sizeof(node));
				node_iconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node1 = node_iconst;
				remove_last_yytext_element();
			}
		| 	CCONST { 
				// printf("limit → CCONST\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_cconst = (node *) malloc(sizeof(node));
				node_cconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node1 = node_cconst;
				remove_last_yytext_element();
			}
		| 	BCONST { 
				// printf("limit → BCONST\n");
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_bconst = (node *) malloc(sizeof(node));
				node_bconst->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node1 = node_bconst;
				remove_last_yytext_element();
			}
		| 	ID { 
				// printf("limit → ID\n");
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("limit");
				$$ = newnode;
				node *node_id = (node *) malloc(sizeof(node));
				node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
				$$->node1 = node_id;
				remove_last_yytext_element();
			}
		;

typename	:	standard_type { 
					// printf("typename → standard_type\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("typename");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	ID { 
					// printf("typename → ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("typename");
					$$ = newnode;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_id;
					remove_last_yytext_element();
				}
			;

standard_type	:	T_INTEGER { 
						// printf("standard_type → T_INTEGER\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("standard_type");
						$$ = newnode;
						node *node_integer = (node *) malloc(sizeof(node));
						node_integer->value = strdup("integer");
						$$->node1 = node_integer;
					}
				| 	T_REAL { 
						// printf("standard_type → T_REAL\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("standard_type");
						$$ = newnode;
						node *node_integer = (node *) malloc(sizeof(node));
						node_integer->value = strdup("real");
						$$->node1 = node_integer;
					}
				| 	T_BOOLEAN { 
						// printf("standard_type → T_BOOLEAN\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("standard_type");
						$$ = newnode;
						node *node_integer = (node *) malloc(sizeof(node));
						node_integer->value = strdup("boolean");
						$$->node1 = node_integer;
					}
				| 	T_CHAR { 
						// printf("standard_type → T_CHAR\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("standard_type");
						$$ = newnode;
						node *node_integer = (node *) malloc(sizeof(node));
						node_integer->value = strdup("char");
						$$->node1 = node_integer;
					}
				;

fields	:	fields SEMI field { 
				// printf("fields → fields SEMI field\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("fields");
				$$ = newnode;
				$$->node1 = $1;
				node *node_semi = (node *) malloc(sizeof(node));
				node_semi->value = strdup(";");
				$$->node2 = node_semi;
				$$->node3 = $3;
			}
		| 	field { 
				// printf("fields → field\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("fields");
				$$ = newnode;
				$$->node1 = $1;
			}
		;

field	:	identifiers COLON typename { 
				// printf("field → identifiers COLON typename\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("field");
				$$ = newnode;
				$$->node1 = $1;
				node *node_colon = (node *) malloc(sizeof(node));
				node_colon->value = strdup(":");
				$$->node2 = node_colon;
				$$->node3 = $3;
			}
		;

identifiers	:	identifiers COMMA ID { 
					// printf("identifiers → identifiers COMMA ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("identifiers");
					$$ = newnode;
					$$->node1 = $1;
					node *node_comma = (node *) malloc(sizeof(node));
					node_comma->value = strdup(",");
					$$->node2 = node_comma;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node3 = node_id;
					remove_last_yytext_element();
				}
			|	ID { 
					// printf("identifiers → ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("identifiers");
					$$ = newnode;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_id;
					remove_last_yytext_element();
				}
			;

vardefs	:	T_VAR variable_defs SEMI { 
				// printf("vardefs → T_VAR variable_defs SEMI\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("vardefs");
				$$ = newnode;
				node *node_var = (node *) malloc(sizeof(node));
				node_var->value = strdup("var");
				$$->node1 = node_var;
				$$->node2 = $2;
				node *node_semi = (node *) malloc(sizeof(node));
				node_semi->value = strdup(";");
				$$->node3 = node_semi;
			}
		| 	{ 
				// printf("vardefs → ε\n");
				$$ = NULL;
			}
		;

variable_defs	:	variable_defs SEMI identifiers COLON typename { 
						// printf("variable_defs → variable_defs SEMI identifiers COLON typename\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("variable_defs");
						$$ = newnode;
						$$->node1 = $1;
						node *node_semi = (node *) malloc(sizeof(node));
						node_semi->value = strdup(";");
						$$->node2 = node_semi;
						$$->node3 = $3;
						node *node_colon = (node *) malloc(sizeof(node));
						node_colon->value = strdup(":");
						$$->node4 = node_colon;
						$$->node5 = $5;
					}
				| 	identifiers COLON typename {
						// printf("variable_defs → identifiers COLON typename\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("variable_defs");
						$$ = newnode;
						$$->node1 = $1;
						node *node_colon = (node *) malloc(sizeof(node));
						node_colon->value = strdup(":");
						$$->node2 = node_colon;
						$$->node3 = $3;
					}
				;

subprograms	:	subprograms subprogram SEMI { 
					// printf("subprograms → subprograms subprogram SEMI\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("subprograms");
					$$ = newnode;
					$$->node1 = $1;
					$$->node2 = $2;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node3 = node_semi;
				}
			| 	{
					// printf("subprograms → ε\n");
					$$ = NULL;
				}
			;

subprogram	:	sub_header SEMI T_FORWARD { 
					// printf("subprogram → sub_header SEMI T_FORWARD\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("subprogram");
					$$ = newnode;
					$$->node1 = $1;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node2 = node_semi;
					node *node_forward = (node *) malloc(sizeof(node));
					node_forward->value = strdup("forward");
					$$->node3 = node_forward;
				}
			| 	sub_header SEMI declarations subprograms comp_statement { 
					// printf("subprogram → sub_header SEMI declarations subprograms comp_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("subprogram");
					$$ = newnode;
					$$->node1 = $1;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node2 = node_semi;
					$$->node3 = $3;
					$$->node4 = $4;
					$$->node5 = $5;
				}
			;

sub_header	:	T_FUNCTION ID formal_parameters COLON standard_type { 
					// printf("sub_header → T_FUNCTION ID formal_parameters COLON standard_type\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("sub_header");
					$$ = newnode;
					node *node_function = (node *) malloc(sizeof(node));
					node_function->value = strdup("function");
					$$->node1 = node_function;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node2 = node_id;
					$$->node3 = $3;
					node *node_colon = (node *) malloc(sizeof(node));
					node_colon->value = strdup(":");
					$$->node4 = node_colon;
					$$->node5 = $5;
					remove_last_yytext_element();
				}
			|	T_PROCEDURE ID formal_parameters { 
					// printf("sub_header → T_PROCEDURE ID formal_parameters\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("sub_header");
					$$ = newnode;
					node *node_procedure = (node *) malloc(sizeof(node));
					node_procedure->value = strdup("procedure");
					$$->node1 = node_procedure;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node2 = node_id;
					$$->node3 = $3;
					remove_last_yytext_element();
				}
			|	T_FUNCTION ID { 
					// printf("sub_header → T_FUNCTION ID\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("sub_header");
					$$ = newnode;
					node *node_function = (node *) malloc(sizeof(node));
					node_function->value = strdup("function");
					$$->node1 = node_function;
					node *node_id = (node *) malloc(sizeof(node));
					node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node2 = node_id;
					remove_last_yytext_element();
				}
			;

formal_parameters	:	LPAREN parameter_list RPAREN { 
							// printf("formal_parameters → LPAREN parameter_list RPAREN\n"); 
							node *newnode = (node *) malloc(sizeof(node));
							newnode->value = strdup("formal_parameters");
							$$ = newnode;
							node *node_lparen = (node *) malloc(sizeof(node));
							node_lparen->value = strdup("(");
							$$->node1 = node_lparen;
							$$->node2 = $2;
							node *node_rparen = (node *) malloc(sizeof(node));
							node_rparen->value = strdup(")");
							$$->node3 = node_rparen;
						}
					| 	{ 
							// printf("formal_parameters → ε\n"); 
							$$ = NULL;
						}
					;

parameter_list	:	parameter_list SEMI pass identifiers COLON typename { 
						// printf("parameter_list → parameter_list SEMI pass identifiers COLON typename\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("parameter_list");
						$$ = newnode;
						$$->node1 = $1;
						node *node_semi = (node *) malloc(sizeof(node));
						node_semi->value = strdup(";");
						$$->node2 = node_semi;
						$$->node3 = $3;
						$$->node4 = $4;
						node *node_colon = (node *) malloc(sizeof(node));
						node_colon->value = strdup(":");
						$$->node5 = node_colon;
						$$->node6 = $6;
					}
				| 	pass identifiers COLON typename { 
						// printf("parameter_list → pass identifiers COLON typename\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("parameter_list");
						$$ = newnode;
						$$->node1 = $1;
						$$->node2 = $2;
						node *node_colon = (node *) malloc(sizeof(node));
						node_colon->value = strdup(":");
						$$->node3 = node_colon;
						$$->node4 = $4;
					}
				;

pass	:	T_VAR { 
				// printf("pass → T_VAR\n"); 
				node *newnode = (node *) malloc(sizeof(node));
				newnode->value = strdup("pass");
				$$ = newnode;
				node *node_var = (node *) malloc(sizeof(node));
				node_var->value = strdup("var");
				$$->node1 = node_var;
			}
		| 	{ 
				// printf("pass → ε\n"); 
				$$ = NULL;
			}
		;

comp_statement	:	T_BEGIN statements T_END { 
						// printf("comp_statement → T_BEGIN statements T_END\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("comp_statement");
						$$ = newnode;
						node *node_begin = (node *) malloc(sizeof(node));
						node_begin->value = strdup("begin");
						$$->node1 = node_begin;
						$$->node2 = $2;
						node *node_end = (node *) malloc(sizeof(node));
						node_end->value = strdup("end");
						$$->node3 = node_end;
					}
				;

statements	:	statements SEMI statement { 
					// printf("statements → statements SEMI statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statements");
					$$ = newnode;
					$$->node1 = $1;
					node *node_semi = (node *) malloc(sizeof(node));
					node_semi->value = strdup(";");
					$$->node2 = node_semi;
					$$->node3 = $3;
				}
			| 	statement { 
					// printf("statements → statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statements");
					$$ = newnode;
					$$->node1 = $1;
				}
			;

statement	:	assignment { 
					// printf("statement → assignment\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	if_statement { 
					// printf("statement → if_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	while_statement { 
					// printf("statement → while_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	for_statement { 
					// printf("statement → for_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	with_statement { 
					// printf("statement → with_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	subprogram_call { 
					// printf("statement → subprogram_call\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	io_statement { 
					// printf("statement → io_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	comp_statement { 
					// printf("statement → comp_statement\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("statement");
					$$ = newnode;
					$$->node1 = $1;
				}
			|	{ 
					// printf("statement → ε\n"); 
					$$ = NULL;
				}
			;

assignment	:	variable ASSIGN expression { 
					// printf("assignment → variable ASSIGN expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("assignment");
					$$ = newnode;
					$$->node1 = $1;
					node *node_assign = (node *) malloc(sizeof(node));
					node_assign->value = strdup(":=");
					$$->node2 = node_assign;
					$$->node3 = $3;
				}
			| 	variable ASSIGN STRING { 
					// printf("assignment → variable ASSIGN STRING\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("assignment");
					$$ = newnode;
					$$->node1 = $1;
					node *node_assign = (node *) malloc(sizeof(node));
					node_assign->value = strdup(":=");
					$$->node2 = node_assign;
					node *node_string = (node *) malloc(sizeof(node));
					node_string->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node3 = node_string;
					remove_last_yytext_element();
				}
			;

if_statement	:	T_IF expression T_THEN statement {
						// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("if_statement");
						$$ = newnode;
						node *node_if = (node *) malloc(sizeof(node));
						node_if->value = strdup("if");
						$$->node1 = node_if;
						$$->node2 = $2;
						node *node_then = (node *) malloc(sizeof(node));
						node_then->value = strdup("then");
						$$->node3 = node_then;
						$$->node4 = $4;
					}
					| T_IF expression T_THEN statement T_ELSE statement {
						// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("if_statement");
						$$ = newnode;
						node *node_if = (node *) malloc(sizeof(node));
						node_if->value = strdup("if");
						$$->node1 = node_if;
						$$->node2 = $2;
						node *node_then = (node *) malloc(sizeof(node));
						node_then->value = strdup("then");
						$$->node3 = node_then;
						$$->node4 = $4;
						node *node_else = (node *) malloc(sizeof(node));
						node_else->value = strdup("else");
						$$->node5 = node_else;
						$$->node6 = $6;
					}
				;

while_statement	:	T_WHILE expression T_DO statement { 
						// printf("while_statement → T_WHILE expression T_DO statement\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("while_statement");
						$$ = newnode;
						node *node_while = (node *) malloc(sizeof(node));
						node_while->value = strdup("while");
						$$->node1 = node_while;
						$$->node2 = $2;
						node *node_do = (node *) malloc(sizeof(node));
						node_do->value = strdup("do");
						$$->node3 = node_do;
						$$->node4 = $4;
					}
				;

for_statement	:	T_FOR ID ASSIGN iter_space T_DO statement {
						// printf("for_statement → T_FOR ID ASSIGN iter_space T_DO statement\n");
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("for_statement");
						$$ = newnode;
						node *node_for = (node *) malloc(sizeof(node));
						node_for->value = strdup("for");
						$$->node1 = node_for;
						node *node_id = (node *) malloc(sizeof(node));
						node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
						$$->node2 = node_id;
						node *node_assign = (node *) malloc(sizeof(node));
						node_assign->value = strdup(":=");
						$$->node3 = node_assign;
						$$->node4 = $4;
						node *node_do = (node *) malloc(sizeof(node));
						node_do->value = strdup("do");
						$$->node5 = node_do;
						$$->node6 = $6;
						remove_last_yytext_element();
					}
				;

iter_space	:	expression T_TO expression { 
					// printf("iter_space → expression T_TO expression\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("iter_space");
					$$ = newnode;
					$$->node1 = $1;
					node *node_to = (node *) malloc(sizeof(node));
					node_to->value = strdup("to");
					$$->node2 = node_to;
					$$->node3 = $3;
				}
			| 	expression T_DOWNTO expression { 
					// printf("iter_space → expression T_DOWNTO expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("iter_space");
					$$ = newnode;
					$$->node1 = $1;
					node *node_to = (node *) malloc(sizeof(node));
					node_to->value = strdup("downto");
					$$->node2 = node_to;
					$$->node3 = $3;
				}
			;


with_statement	:	T_WITH variable T_DO statement { 
						// printf("with_statement → T_WITH variable T_DO statement\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("with_statement");
						$$ = newnode;
						node *node_with = (node *) malloc(sizeof(node));
						node_with->value = strdup("with");
						$$->node1 = node_with;
						$$->node2 = $2;
						node *node_to = (node *) malloc(sizeof(node));
						node_to->value = strdup("do");
						$$->node3 = node_to;
						$$->node4 = $4;
					}
				;

subprogram_call	:	ID {
						//  printf("subprogram_call → ID\n");
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("subprogram_call");
						$$ = newnode;
						node *node_id = (node *) malloc(sizeof(node));
						node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
						$$->node1 = node_id;
						remove_last_yytext_element();
					}
				| 	ID LPAREN expressions RPAREN { 
						// printf("subprogram_call → ID LPAREN expressions RPAREN\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("subprogram_call");
						$$ = newnode;
						node *node_id = (node *) malloc(sizeof(node));
						node_id->value = strdup(yytexts->yytext[yytexts->slots-1]);
						$$->node1 = node_id;
						node *node_lparen = (node *) malloc(sizeof(node));
						node_lparen->value = strdup("(");
						$$->node2 = node_lparen;
						$$->node3 = $3;
						node *node_rparen = (node *) malloc(sizeof(node));
						node_rparen->value = strdup(")");
						$$->node4 = node_rparen;
						remove_last_yytext_element();
					}
				;

io_statement	:	T_READ LPAREN read_list RPAREN { 
						// printf("io_statement → T_READ LPAREN read_list RPAREN\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("io_statement");
						$$ = newnode;
						node *node_read = (node *) malloc(sizeof(node));
						node_read->value = strdup("read");
						$$->node1 = node_read;
						node *node_lparen = (node *) malloc(sizeof(node));
						node_lparen->value = strdup("(");
						$$->node2 = node_lparen;
						$$->node3 = $3;
						node *node_rparen = (node *) malloc(sizeof(node));
						node_rparen->value = strdup(")");
						$$->node4 = node_rparen;
					}
				| 	T_WRITE LPAREN write_list RPAREN { 
						// printf("io_statement → T_WRITE LPAREN write_list RPAREN\n"); 
						node *newnode = (node *) malloc(sizeof(node));
						newnode->value = strdup("io_statement");
						$$ = newnode;
						node *node_read = (node *) malloc(sizeof(node));
						node_read->value = strdup("write");
						$$->node1 = node_read;
						node *node_lparen = (node *) malloc(sizeof(node));
						node_lparen->value = strdup("(");
						$$->node2 = node_lparen;
						$$->node3 = $3;
						node *node_rparen = (node *) malloc(sizeof(node));
						node_rparen->value = strdup(")");
						$$->node4 = node_rparen;
					}
				;

read_list	:	read_list COMMA read_item { 
					// printf("read_list → read_list COMMA read_item\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("read_list");
					$$ = newnode;
					$$->node1 = $1;
					node *node_comma = (node *) malloc(sizeof(node));
					node_comma->value = strdup(",");
					$$->node2 = node_comma;
					$$->node3 = $3;
				}
			| 	read_item { 
					// printf("read_list → read_item\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("read_list");
					$$ = newnode;
					$$->node1 = $1;
				}
			;

read_item	:	variable { 
					// printf("read_item → variable\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("read_item");
					$$ = newnode;
					$$->node1 = $1;
				}
			;

write_list	:	write_list COMMA write_item { 
					// printf("write_list → write_list COMMA write_item\n");
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("write_list");
					$$ = newnode;
					$$->node1 = $1;
					node *node_comma = (node *) malloc(sizeof(node));
					node_comma->value = strdup(",");
					$$->node2 = node_comma;
					$$->node3 = $3;
				}
			|	write_item { 
					// printf("write_list → write_item\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("write_list");
					$$ = newnode;
					$$->node1 = $1;
				}
			;

write_item	:	expression { 
					// printf("write_item → expression\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("write_item");
					$$ = newnode;
					$$->node1 = $1;
				}
			| 	STRING { 
					// printf("write_item → STRING\n"); 
					node *newnode = (node *) malloc(sizeof(node));
					newnode->value = strdup("write_item");
					$$ = newnode;
					node *node_string = (node *) malloc(sizeof(node));
					node_string->value = strdup(yytexts->yytext[yytexts->slots-1]);
					$$->node1 = node_string;
					remove_last_yytext_element();
				}
			;
%%

int main () {
	yytexts = (yytexts_ *) malloc(sizeof(yytexts_));
	int ret = yyparse();
	printf("\n-----------\nSyntax tree\n-----------\n\n");
	update_tree_depths(root, 0);
	preorder_tree_traversal(root);
	printf("\n");
  	return ret;
}

