%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/defs.h"
#include "src/hashtable.h"

void yyerror(const char *s);
int yylex();
extern int yylineno;
extern stack_struct* registers_stack;
extern stack_struct* if_statement_stack;
extern stack_struct* while_statement_stack;
node* ast_tree_root;
int error_flag = 0;

%}

%locations

%token 	T_PROGRAM T_CONST T_TYPE T_ARRAY T_SET T_OF T_RECORD T_VAR T_FORWARD 
		T_FUNCTION T_PROCEDURE T_INTEGER T_REAL T_BOOLEAN T_CHAR T_BEGIN T_END
		T_IF T_THEN T_ELSE T_WHILE T_DO T_FOR T_DOWNTO T_TO T_WITH T_READ 
		T_WRITE ADDOP_ADD ADDOP_SUB OROP NOTOP INOP LPAREN RPAREN SEMI DOT 
		COMMA EQU COLON LBRACK RBRACK ASSIGN DOTDOT MULDIVANDOP_MUL 
		MULDIVANDOP_DIV MULDIVANDOP_DIV_E MULDIVANDOP_MOD MULDIVANDOP_AND
		RELOP_NE RELOP_LE RELOP_GE RELOP_LT RELOP_GT 

%nonassoc T_THEN
%nonassoc T_ELSE
%nonassoc 	INOP RELOP_NE RELOP_LE RELOP_GE RELOP_LT RELOP_GT EQU
%left		ADDOP_ADD ADDOP_SUB OROP
%left		MULDIVANDOP_MUL MULDIVANDOP_DIV MULDIVANDOP_DIV_E MULDIVANDOP_MOD MULDIVANDOP_AND
%nonassoc 	NOTOP
%left 		LPAREN RPAREN
%left 		LBRACK RBRACK
%left 		DOT

%union {
	unsigned int integer;
	double real;
	int string_slots;
	char *string;
	char *operator_str;
	char character;
	int boolean;
	node* node;
}

%token <string> ID ICONST BCONST CCONST STRING RCONST RCONST_REAL RCONST_INT RCONST_HEX RCONST_BIN

%type <node> program header declarations constdefs constant_defs expression constant typedefs type_defs 
			 type_def dims limit limits typename standard_type fields field identifiers vardefs variable_defs
			 subprograms subprogram sub_header formal_parameters parameter_list pass comp_statement statements
			 variable statement if_statement assignment expressions subprogram_call setexpression
			 elexpressions elexpression io_statement read_list read_item while_statement for_statement
			 iter_space with_statement write_list write_item

%%

program:		header declarations subprograms comp_statement DOT { 
					// printf("program → header declarations subprograms comp statement DOT\n");
					ast_tree_root = make_node("program", NODE_TYPE_PROGRAM, NULL, $1, $2, $3, $4, NULL, NULL);
				};

header: 		T_PROGRAM ID SEMI {
					// printf("header → T_PROGRAM ID SEMI\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("header", NODE_TYPE_HEADER, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

declarations:	constdefs typedefs vardefs { 
					// printf("declarations → constdefs typedefs vardefs\n");
					$$ = make_node("declarations", NODE_TYPE_DECLARATIONS, NULL, $1, $2, $3, NULL, NULL, NULL);
				};

constdefs:		T_CONST constant_defs SEMI { 
					
					// printf("constdefs → T_CONST constant_defs SEMI\n"); 
					$$ = make_node("constdefs", NODE_TYPE_CONSTDEFS, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	{
					// printf("CONSTDEFS → ε\n");
					$$ = NULL;
				};

constant_defs:	constant_defs SEMI ID EQU expression { 
					// printf("constant_defs → constant_defs SEMI ID EQU expression\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					if ($5->symbol) {
						// parse_value(smbl, $5->symbol, $5->type);
						parse_value(smbl, $5->symbol, $5->type);
					}
					$$ = make_node("constant_defs_0", NODE_TYPE_CONSTANT_DEFS_0, smbl, $1, $5, NULL, NULL, NULL, NULL);
				}
			| 	ID EQU expression {
					// printf("constant_defs → ID EQU expression\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					if ($3->symbol) {
						parse_value(smbl, $3->symbol, $3->type);
					}
					$$ = make_node("constant_defs_1", NODE_TYPE_CONSTANT_DEFS_1, smbl, $3, NULL, NULL, NULL, NULL, NULL);
				};

expression:		expression RELOP_NE expression {
					// printf("expression → expression RELOP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_0)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression RELOP_NE expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_0", NODE_TYPE_EXPRESSION_0, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	expression RELOP_GE expression { 
					// printf("expression → expression RELOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_1)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression RELOP_GE expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_1", NODE_TYPE_EXPRESSION_1, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression RELOP_LE expression {
					// printf("expression → expression RELOP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_2)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression RELOP_LE expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_2", NODE_TYPE_EXPRESSION_2, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression RELOP_LT expression {
					// printf("expression → expression RELOP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_3)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression RELOP_LT expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_3", NODE_TYPE_EXPRESSION_3, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression RELOP_GT expression { 
					// printf("expression → expression RELOP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_4)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression RELOP_GT expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_4", NODE_TYPE_EXPRESSION_4, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression EQU expression {
					// printf("expression → expression EQU expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_5)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression EQU expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_5", NODE_TYPE_EXPRESSION_5, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression INOP expression {
					// printf("expression → expression INOP expression\n");
					$$ = make_node("expression_6", NODE_TYPE_EXPRESSION_6, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression OROP expression {
					// printf("expression → expression OROP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_7)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression OROP expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_7", NODE_TYPE_EXPRESSION_7, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression ADDOP_ADD expression	{
					// printf("expression → expression ADDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_8)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression ADDOP_ADD expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_8", NODE_TYPE_EXPRESSION_8, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression ADDOP_SUB expression	{
					// printf("expression → expression ADDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_9)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression ADDOP_SUB expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_9", NODE_TYPE_EXPRESSION_9, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression MULDIVANDOP_MUL expression {
					// printf("expression → expression MULDIVANDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_10)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression MULDIVANDOP_MUL expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_10", NODE_TYPE_EXPRESSION_10, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression MULDIVANDOP_DIV expression {
					// printf("expression → expression MULDIVANDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_11)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression MULDIVANDOP_DIV expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_11", NODE_TYPE_EXPRESSION_11, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression MULDIVANDOP_DIV_E expression {
					// printf("expression → expression MULDIVANDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_12)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression MULDIVANDOP_DIV_E expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_12", NODE_TYPE_EXPRESSION_12, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression MULDIVANDOP_MOD expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_13)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression MULDIVANDOP_MOD expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_13", NODE_TYPE_EXPRESSION_13, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression MULDIVANDOP_AND expression {
					// printf("expression → expression MULDIVANDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_14)) {
						printf("error at line %d: invalid operand types %d and %d for \"expression MULDIVANDOP_AND expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_14", NODE_TYPE_EXPRESSION_14, smbl, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	ADDOP_ADD expression {
					// printf("expression → ADDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $2->symbol, NULL, NODE_TYPE_EXPRESSION_15)) {
						printf("error at line %d: invalid operand type %d for \"ADDOP_ADD expression\"\n", yylineno, $2->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_15", NODE_TYPE_EXPRESSION_15, smbl, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	ADDOP_SUB expression {
					// printf("expression → ADDOP expression\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $2->symbol, NULL, NODE_TYPE_EXPRESSION_16)) {
						if ($2->symbol) { // TODO CHECK _all(-y[x[0]],xx[y[x[x2]]]);
							printf("error at line %d: invalid operand type %d for \"ADDOP_SUB expression\"\n", yylineno, $2->symbol->typos);
							error_flag = 1;
						}
					}
					$$ = make_node("expression_16", NODE_TYPE_EXPRESSION_16, smbl, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	NOTOP expression {
					// printf("expression → NOTOP expression\n"); 
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $2->symbol, NULL, NODE_TYPE_EXPRESSION_17)) {
						if ($2->symbol) { // TODO CHECK _all(-y[x[0]],xx[y[x[x2]]]);
							printf("error at line %d: invalid operand type %d for \"NOTOP expression\"\n", yylineno, $2->symbol->typos);
							error_flag = 1;
						}
					}
					$$ = make_node("expression_17", NODE_TYPE_EXPRESSION_17, smbl, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	variable {
					// printf("expression → variable\n"); 
					$$ = $1;
				}
			|	ID LPAREN expressions RPAREN {
					// printf("expression → ID LPAREN expressions RPAREN\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("expression_18", NODE_TYPE_EXPRESSION_18, smbl, $3, NULL, NULL, NULL, NULL, NULL);

					// if (find_symbol(smbl)) {
					// 	$$ = make_node("expression_18", NODE_TYPE_EXPRESSION_18, smbl, $3, NULL, NULL, NULL, NULL, NULL);
					// }
					// else {
					// 	printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
					// 	error_flag = 1;
					// }
				}
			|	constant {
					// printf("expression → constant\n"); 
					$$ = $1;
				}
			|	LPAREN expression RPAREN {
					// printf("expression → LPAREN expression RPAREN\n");
					symbol* smbl = new_symbol("");
					if (!evaluate_expression(smbl, $2->symbol, NULL, NODE_TYPE_EXPRESSION_19)) {
						printf("error at line %d: invalid operand type %d for \"(expression)\"\n", yylineno, $2->symbol->typos);
						error_flag = 1;
					}
					$$ = make_node("expression_19", NODE_TYPE_EXPRESSION_19, smbl, $2, NULL, NULL, NULL, NULL, NULL);
					// $$ = make_node("expression_19", NODE_TYPE_EXPRESSION_19, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	setexpression{
					// printf("expression → setexpression\n"); 
					$$ = $1;
				};


variable:		ID {
					// printf("variable → ID\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("variable_0", NODE_TYPE_VARIABLE_0, find_symbol(smbl), NULL, NULL, NULL, NULL, NULL, NULL);
					// if (find_symbol(smbl)) {
					// 	$$ = make_node("variable_0", NODE_TYPE_VARIABLE_0, find_symbol(smbl), NULL, NULL, NULL, NULL, NULL, NULL);
					// }
					// else {
					// 	printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
					// 	error_flag = 1;
					// }
				}
			|	variable DOT ID {
					// printf("variable → variable DOT ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("variable_1", NODE_TYPE_VARIABLE_1, smbl, $1, NULL, NULL, NULL, NULL, NULL);
				}
			|	variable LBRACK expressions RBRACK {
					// printf("variable → variable LBRACK expressions RBRACK\n"); 
					$$ = make_node("variable_2", NODE_TYPE_VARIABLE_2, NULL, $1, $3, NULL, NULL, NULL, NULL);
				};

expressions:	expressions COMMA expression { 
					// printf("expressions → expressions COMMA expression\n"); 
					$$ = make_node("expressions", NODE_TYPE_EXPRESSIONS, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression {
					// printf("expressions → expression\n"); 
					$$ = $1;
				};

constant:		ICONST {
					// printf("constant → ICONST\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					parse_value(smbl, smbl, NODE_TYPE_CONSTANT_0);
					$$ = make_node("constant_0", NODE_TYPE_CONSTANT_0, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			|	RCONST {
					symbol* smbl = new_symbol(pop(yytext_stack));
					parse_value(smbl, smbl, NODE_TYPE_CONSTANT_1);
					$$ = make_node("constant_1", NODE_TYPE_CONSTANT_1, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	BCONST {
					// printf("constant → BCONST\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					parse_value(smbl, smbl, NODE_TYPE_CONSTANT_5);
					$$ = make_node("constant_5", NODE_TYPE_CONSTANT_5, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	CCONST {
					// printf("constant → CCONST\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					parse_value(smbl, smbl, NODE_TYPE_CONSTANT_6);
					$$ = make_node("constant_6", NODE_TYPE_CONSTANT_6, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

setexpression: 	LBRACK elexpressions RBRACK {
					// printf("setexpression → LBRACK elexpressions RBRACK\n"); 
					$$ = make_node("setexpression_0", NODE_TYPE_SETEXPRESSION_0, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			| 	LBRACK RBRACK {
					// printf("setexpression → LBRACK RBRACK\n"); 
					$$ = make_node("setexpression_1", NODE_TYPE_SETEXPRESSION_1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				};

elexpressions:	elexpressions COMMA elexpression {
					// printf("elexpressions → elexpressions COMMA elexpression\n"); 
					$$ = make_node("elexpressions", NODE_TYPE_ELEXPRESSIONS, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	elexpression {
					// printf("elexpressions → elexpression\n");
					$$ = $1;
				};

elexpression:	expression DOTDOT expression {
					// printf("elexpression → expression DOTDOT expression\n"); 
					$$ = make_node("elexpression", NODE_TYPE_ELEXPRESSION, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	expression{
					// printf("elexpression → expression\n"); 
					$$ = $1;
				};

typedefs:		T_TYPE type_defs SEMI	{
					// printf("typedefs → T_TYPE type_defs SEMI\n");
					$$ = make_node("typedefs", NODE_TYPE_TYPEDEFS, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			| 	{
					// printf("typedefs → ε\n"); 
					$$ = NULL;
				};

type_defs:		type_defs SEMI ID EQU type_def { 
					// printf("type_defs → type_defs SEMI ID EQU type_def\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("type_defs_0", NODE_TYPE_TYPE_DEFS_0, smbl, $1, $5, NULL, NULL, NULL, NULL);
				}
			| 	ID EQU type_def {
					// printf("type_defs → ID EQU type_def\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("type_defs_1", NODE_TYPE_TYPE_DEFS_1, smbl, $3, NULL, NULL, NULL, NULL, NULL);
				};

type_def:		T_ARRAY LBRACK dims RBRACK T_OF typename {
					// printf("type_def → T_ARRAY LBRACK dims RBRACK T_OF typename\n"); 
					$$ = make_node("type_def_0", NODE_TYPE_TYPE_DEF_0, NULL, $3, $6, NULL, NULL, NULL, NULL);
				}
			|	T_SET T_OF typename {
					// printf("type_def → T_SET T_OF typename\n"); 
					$$ = make_node("type_def_1", NODE_TYPE_TYPE_DEF_1, NULL, $3, NULL, NULL, NULL, NULL, NULL);
				}
			|	T_RECORD fields T_END {
					// printf("type_def → T_RECORD fields T_END\n"); 
					$$ = make_node("type_def_2", NODE_TYPE_TYPE_DEF_2, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	LPAREN identifiers RPAREN {
					// printf("type_def → LPAREN identifiers RPAREN\n"); 
					$$ = make_node("type_def_3", NODE_TYPE_TYPE_DEF_3, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			|	limit DOTDOT limit {
					// printf("type_def → limit DOTDOT limit\n"); 
					$$ = make_node("type_def_4", NODE_TYPE_TYPE_DEF_4, NULL, $1, $3, NULL, NULL, NULL, NULL);
				};

dims:			dims COMMA limits {
					// printf("dims → dims COMMA limits\n"); 
					$$ = make_node("dims", NODE_TYPE_DIMS, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	limits {
					// printf("dims → limits\n"); 
					$$ = $1;
				};

limits:			limit DOTDOT limit {
					// printf("limits → limit DOTDOT limit\n"); 
					$$ = make_node("limits_0", NODE_TYPE_LIMITS_0, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	ID {
					// printf("limits → ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("limits_1", NODE_TYPE_LIMITS_1, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

limit:			ADDOP_ADD ICONST{
					// printf("limit → ADDOP ICONST\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("limit_0", NODE_TYPE_LIMIT_0, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			|	ADDOP_SUB ICONST {
					// printf("limit → ADDOP ICONST\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("limit_1", NODE_TYPE_LIMIT_1, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	ADDOP_ADD ID {
					// printf("limit → ADDOP ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("limit_2", NODE_TYPE_LIMIT_2, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
					// if (find_symbol(smbl)) {
					// 	$$ = make_node("limit_2", NODE_TYPE_LIMIT_2, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
					// }
					// else {
					// 	printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
					// 	error_flag = 1;
					// }
				}
			| 	ADDOP_SUB ID {
					// printf("limit → ADDOP ID\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("limit_3", NODE_TYPE_LIMIT_3, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	ICONST {
					// printf("limit → ICONST\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("limit_4", NODE_TYPE_LIMIT_4, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	CCONST {
					// printf("limit → CCONST\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("limit_5", NODE_TYPE_LIMIT_5, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	BCONST {
					// printf("limit → BCONST\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("limit_6", NODE_TYPE_LIMIT_6, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	ID {
					// printf("limit → ID\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("limit_7", NODE_TYPE_LIMIT_7, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

typename:		standard_type {
					// printf("typename → standard_type\n");
					$$ = $1;
				}
			| 	ID {
					// printf("typename → ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("typename", NODE_TYPE_TYPENAME, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

standard_type:	T_INTEGER { 
					// printf("standard_type → T_INTEGER\n"); 
					$$ = make_node("integer", NODE_TYPE_INTEGER, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	T_REAL {
					// printf("standard_type → T_REAL\n"); 
					$$ = make_node("real", NODE_TYPE_REAL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	T_BOOLEAN {
					// printf("standard_type → T_BOOLEAN\n"); 
					$$ = make_node("boolean", NODE_TYPE_BOOLEAN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	T_CHAR {
					// printf("standard_type → T_CHAR\n"); 
					$$ = make_node("char", NODE_TYPE_CHAR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				};

fields:			fields SEMI field {
					// printf("fields → fields SEMI field\n"); 
					$$ = make_node("fields_0", NODE_TYPE_FIELDS_0, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	field {
					// printf("fields → field\n"); 
					$$ = make_node("fields_1", NODE_TYPE_FIELDS_1, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				};

field:			identifiers COLON typename {
					// printf("field → identifiers COLON typename\n"); 
					$$ = make_node("field", NODE_TYPE_FIELD, NULL, $1, $3, NULL, NULL, NULL, NULL);
				};

identifiers:	identifiers COMMA ID { 
					// printf("identifiers → identifiers COMMA ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("identifiers_0", NODE_TYPE_IDENTIFIERS_0, smbl, $1, NULL, NULL, NULL, NULL, NULL);
				}
			|	ID {
					// printf("identifiers → ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("identifiers_1", NODE_TYPE_IDENTIFIERS_1, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

vardefs:		T_VAR variable_defs SEMI {
					// printf("vardefs → T_VAR variable_defs SEMI\n"); 
					$$ = make_node("vardefs", NODE_TYPE_VARDEFS, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				}
			| 	{ 
					// printf("vardefs → ε\n");
					$$ = NULL;
				};

variable_defs:	variable_defs SEMI identifiers COLON typename {
					// printf("variable_defs → variable_defs SEMI identifiers COLON typename\n"); 
					$$ = make_node("variable_defs_0", NODE_TYPE_VARIABLE_DEFS_0, NULL, $1, $3, $5, NULL, NULL, NULL);
				}
			| 	identifiers COLON typename {
					// printf("variable_defs → identifiers COLON typename\n"); 
					$$ = make_node("variable_defs_1", NODE_TYPE_VARIABLE_DEFS_1, NULL, $1, $3, NULL, NULL, NULL, NULL);
				};

subprograms:	subprograms subprogram SEMI {
					// printf("subprograms → subprograms subprogram SEMI\n");
					$$ = make_node("subprograms", NODE_TYPE_SUBPROGRAMS, NULL, $1, $2, NULL, NULL, NULL, NULL);
				}
			| 	{
					// printf("subprograms → ε\n");
					$$ = NULL;
				};

subprogram	:	sub_header SEMI T_FORWARD { 
					// printf("subprogram → sub_header SEMI T_FORWARD\n"); 
					$$ = make_node("subprogram_0", NODE_TYPE_SUBPROGRAM_0, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	sub_header SEMI declarations subprograms comp_statement { 
					// printf("subprogram → sub_header SEMI declarations subprograms comp_statement\n"); 
					$$ = make_node("subprogram_1", NODE_TYPE_SUBPROGRAM_1, NULL, $1, $3, $4, $5, NULL, NULL);
				};

sub_header:		T_FUNCTION ID formal_parameters COLON standard_type {
					// printf("sub_header → T_FUNCTION ID formal_parameters COLON standard_type\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("sub_header_0", NODE_TYPE_SUB_HEADER_0, smbl, $3, $5, NULL, NULL, NULL, NULL);
				}
			|	T_PROCEDURE ID formal_parameters { 
					// printf("sub_header → T_PROCEDURE ID formal_parameters\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("sub_header_1", NODE_TYPE_SUB_HEADER_1, smbl, $3, NULL, NULL, NULL, NULL, NULL);
				}
			|	T_FUNCTION ID { 
					// printf("sub_header → T_FUNCTION ID\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					add_symbol(smbl);
					$$ = make_node("sub_header_2", NODE_TYPE_SUB_HEADER_2, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

formal_parameters:	LPAREN parameter_list RPAREN {
						// printf("formal_parameters → LPAREN parameter_list RPAREN\n"); 
						$$ = make_node("formal_parameters", NODE_TYPE_FORMAL_PARAMETERS, NULL, $2, NULL, NULL, NULL, NULL, NULL);
					}
				| 	{ 
						// printf("formal_parameters → ε\n"); 
						$$ = NULL;
					};

parameter_list:	parameter_list SEMI pass identifiers COLON typename {
					// printf("parameter_list → parameter_list SEMI pass identifiers COLON typename\n"); 
					$$ = make_node("parameter_list_0", NODE_TYPE_PARAMETER_LIST_0, NULL, $1, $3, $4, $6, NULL, NULL);
				}
			| 	pass identifiers COLON typename { 
					// printf("parameter_list → pass identifiers COLON typename\n");
					$$ = make_node("parameter_list_1", NODE_TYPE_PARAMETER_LIST_1, NULL, $1, $2, $4, NULL, NULL, NULL);
				};

pass:			T_VAR {
					// printf("pass → T_VAR\n"); 
					$$ = make_node("var", NODE_TYPE_VAR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
				}
			| 	{
					// printf("pass → ε\n");
					$$ = NULL;
				}
				;

comp_statement:	T_BEGIN statements T_END {
					// printf("comp_statement → T_BEGIN statements T_END\n"); 
					$$ = make_node("comp_statement", NODE_TYPE_COMP_STATEMENT, NULL, $2, NULL, NULL, NULL, NULL, NULL);
				};

statements:		statements SEMI statement{
					// printf("statements → statements SEMI statement\n"); 
					$$ = make_node("statements", NODE_TYPE_STATEMENTS, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	statement { 
					// printf("statements → statement\n"); 
					$$ = $1;
				};

statement:		assignment {
					// printf("statement → assignment\n"); 
					$$ = $1;
				}
			| 	if_statement { 
					// printf("statement → if_statement\n"); 
					$$ = $1;
				}
			| 	while_statement {
					// printf("statement → while_statement\n"); 
					$$ = $1;
				}
			| 	for_statement {
					// printf("statement → for_statement\n"); 
					$$ = $1;
				}
			| 	with_statement {
					// printf("statement → with_statement\n"); 
					$$ = $1;
				}
			| 	subprogram_call {
					// printf("statement → subprogram_call\n"); 
					$$ = $1;
				}
			| 	io_statement {
					// printf("statement → io_statement\n"); 
					$$ = $1;
				}
			| 	comp_statement {
					// printf("statement → comp_statement\n"); 
					$$ = $1;
				}
			|	{ 
					// printf("statement → ε\n"); 
					$$ = NULL;
				};

assignment:		variable ASSIGN expression {
					// printf("assignment → variable ASSIGN expression\n");
					// symbol* smbl = new_symbol("");
					// if (!evaluate_expression(smbl, $1->symbol, $3->symbol, NODE_TYPE_EXPRESSION_11)) {
					// 	printf("error at line %d: invalid operand types %d and %d for \"variable ASSIGN expression\"\n", yylineno, $1->symbol->typos, $3->symbol->typos);
					// 	error_flag = 1;
					// }
					// $$ = make_node("assignment_0", NODE_TYPE_ASSIGNMENT_0, smbl, $1, $3, NULL, NULL, NULL, NULL);
					$$ = make_node("assignment_0", NODE_TYPE_ASSIGNMENT_0, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	variable ASSIGN STRING {
					// printf("assignment → variable ASSIGN STRING\n"); 
					symbol* smbl = new_symbol(pop(yytext_stack));
					$$ = make_node("assignment_1", NODE_TYPE_ASSIGNMENT_1, smbl, $1, NULL, NULL, NULL, NULL, NULL);
				};

if_statement:	T_IF expression T_THEN statement {
					// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
					$$ = make_node("if_statement_0", NODE_TYPE_IF_STATEMENT_0, NULL, $2, $4, NULL, NULL, NULL, NULL);
				}
			|	T_IF expression T_THEN statement T_ELSE statement {
					// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
					$$ = make_node("if_statement_1", NODE_TYPE_IF_STATEMENT_1, NULL, $2, $4, $6, NULL, NULL, NULL);
				};

while_statement:	T_WHILE expression T_DO statement {
						// printf("while_statement → T_WHILE expression T_DO statement\n"); 
						$$ = make_node("while_statement", NODE_TYPE_WHILE_STATEMENT, NULL, $2, $4, NULL, NULL, NULL, NULL);
					};

for_statement:	T_FOR ID ASSIGN iter_space T_DO statement {
					// printf("for_statement → T_FOR ID ASSIGN iter_space T_DO statement\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					if (!find_symbol(smbl)) {
						printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						error_flag = 1;
					}
					$$ = make_node("for_statement", NODE_TYPE_FOR_STATEMENT, smbl, $4, $6, NULL, NULL, NULL, NULL);
				};

iter_space	:	expression T_TO expression { 
					// printf("iter_space → expression T_TO expression\n");
					$$ = make_node("iter_space_0", NODE_TYPE_ITER_SPACE_0, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	expression T_DOWNTO expression { 
					// printf("iter_space → expression T_DOWNTO expression\n"); 
					$$ = make_node("iter_space_1", NODE_TYPE_ITER_SPACE_1, NULL, $1, $3, NULL, NULL, NULL, NULL);
				};


with_statement:	T_WITH variable T_DO statement {
					// printf("with_statement → T_WITH variable T_DO statement\n"); 
					$$ = make_node("with_statement", NODE_TYPE_WITH_STATEMENT, NULL, $2, $4, NULL, NULL, NULL, NULL);
				};

subprogram_call:	ID {
						//  printf("subprogram_call → ID\n");
						symbol* smbl = new_symbol(pop(yytext_stack));
						if (!find_symbol(smbl)) {
							printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
							error_flag = 1;
						}
						$$ = make_node("subprogram_call_0", NODE_TYPE_SUBPROGRAM_CALL_0, smbl, NULL, NULL, NULL, NULL, NULL, NULL);

						// if (find_symbol(smbl)) {
						// 	$$ = make_node("subprogram_call_0", NODE_TYPE_SUBPROGRAM_CALL_0, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
						// }
						// else {
						// 	printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						// 	error_flag = 1;
						// }
					}
				| 	ID LPAREN expressions RPAREN{
						// printf("subprogram_call → ID LPAREN expressions RPAREN\n");
						symbol* smbl = new_symbol(pop(yytext_stack));
						
						if (!find_symbol(smbl)) {
							printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
							error_flag = 1;
						}
						$$ = make_node("subprogram_call_1", NODE_TYPE_SUBPROGRAM_CALL_1, smbl, $3, NULL, NULL, NULL, NULL, NULL);

						// if (find_symbol(smbl)) {
						// 	$$ = make_node("subprogram_call_1", NODE_TYPE_SUBPROGRAM_CALL_1, smbl, $3, NULL, NULL, NULL, NULL, NULL);
						// }
						// else {
						// 	printf("error at line %d: undeclared symbol \"%s\"\n", yylineno, smbl->name);
						// 	error_flag = 1;
						// }
					};

io_statement:	T_READ LPAREN read_list RPAREN {
					// printf("io_statement → T_READ LPAREN read_list RPAREN\n"); 
					$$ = make_node("io_statement_0", NODE_TYPE_IO_STATEMENT_0, NULL, $3, NULL, NULL, NULL, NULL, NULL);
				}
			| 	T_WRITE LPAREN write_list RPAREN {
					// printf("io_statement → T_WRITE LPAREN write_list RPAREN\n"); 
					$$ = make_node("io_statement_1", NODE_TYPE_IO_STATEMENT_1, NULL, $3, NULL, NULL, NULL, NULL, NULL);
				};

read_list:		read_list COMMA read_item {
					// printf("read_list → read_list COMMA read_item\n"); 
					$$ = make_node("read_list", NODE_TYPE_READ_LIST, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			| 	read_item { 
					// printf("read_list → read_item\n"); 
					$$ = $1;
				};

read_item:		variable {
					// printf("read_item → variable\n"); 
					$$ = $1;
				};

write_list:		write_list COMMA write_item {
					// printf("write_list → write_list COMMA write_item\n");
					$$ = make_node("write_list", NODE_TYPE_WRITE_LIST, NULL, $1, $3, NULL, NULL, NULL, NULL);
				}
			|	write_item {
					// printf("write_list → write_item\n");
					$$ = $1;
				};

write_item:		expression { 
					// printf("write_item → expression\n"); 
					$$ = $1;
				}
			| 	STRING {
					// printf("write_item → STRING\n");
					symbol* smbl = new_symbol(pop(yytext_stack));
					smbl->typos = SYMBOL_TYPE_STRING;
					$$ = make_node("write_item", NODE_TYPE_WRITE_ITEM, smbl, NULL, NULL, NULL, NULL, NULL, NULL);
				};

%%

int main () {
	Symbol_free = NULL;
	initialize_hashtable(10);
	yytext_stack = (stack_struct *) malloc(sizeof(stack_struct));
	yytext_stack->type = STACK_TYPE_STRING;
	registers_stack = (stack_struct *) malloc(sizeof(stack_struct));
	registers_stack->type = STACK_TYPE_ICONST;
	if_statement_stack = (stack_struct *) malloc(sizeof(stack_struct));
	if_statement_stack->type = STACK_TYPE_ICONST;
	while_statement_stack = (stack_struct *) malloc(sizeof(stack_struct));
	while_statement_stack->type = STACK_TYPE_ICONST;
	int ret = yyparse();
	
	if (error_flag) {
		printf("\n\n\n");
		hashtable_get();
		printf("\n[-] too many errors, exiting\n");
		exit(1);
	}
	else {
		printf("\n--------------------\nAbstract Syntax Tree\n--------------------\n\n");
		preorder_tree_traversal(ast_tree_root, 0);
		printf("\n\n\n");
		hashtable_get();
		printf("\n\n----\nCode\n----\n\n");
		generate_code(ast_tree_root);
		printf("\n");
	}
  	return ret;
}

