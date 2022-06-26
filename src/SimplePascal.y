%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "src/defs.h"
#include "src/hashtable.h"

void yyerror(const char *s);
int yylex();
extern int yylineno;

node* parse_tree_root;
node* ast_tree_root;

%}

%locations

%token 	T_PROGRAM T_CONST T_TYPE T_ARRAY T_SET T_OF T_RECORD T_VAR T_FORWARD T_FUNCTION T_PROCEDURE
		T_INTEGER T_REAL T_BOOLEAN T_CHAR T_BEGIN T_END T_IF T_THEN T_ELSE T_WHILE T_DO T_FOR 
		T_DOWNTO T_TO T_WITH T_READ T_WRITE ADDOP_ADD ADDOP_SUB OROP NOTOP INOP LPAREN RPAREN 
		SEMI DOT COMMA EQU COLON LBRACK RBRACK ASSIGN DOTDOT
		MULDIVANDOP_MUL MULDIVANDOP_DIV MULDIVANDOP_DIV_E MULDIVANDOP_MOD MULDIVANDOP_AND
		RELOP_NE RELOP_LE RELOP_GE RELOP_LT RELOP_GT 

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
	node* node;
	parse_and_syntax_tree* parse_and_syntax_tree;
}

%token <string> ID ICONST BCONST CCONST STRING RCONST_REAL RCONST_INT RCONST_HEX RCONST_BIN

%type <node> program header declarations constdefs constant_defs expression constant typedefs type_defs 
			 type_def dims limit limits typename standard_type fields field identifiers vardefs variable_defs
			 subprograms subprogram sub_header formal_parameters parameter_list pass comp_statement statements
			 variable statement if_statement assignment expressions subprogram_call setexpression
			 elexpressions elexpression io_statement read_list read_item while_statement for_statement
			 iter_space with_statement write_list write_item

%%

program : 	header declarations subprograms comp_statement DOT { 
				// printf("program → header declarations subprograms comp statement DOT\n");
				ast_tree_root = make_node("program", NODETYPE_PROGRAM, NULL, $1, $2, $3, $4, NULL, NULL);
			}
		;

header	: 	T_PROGRAM ID SEMI { 
				// printf("header → T_PROGRAM ID SEMI\n");
				symbol* symbol_id = new_symbol(pop_yytext_stack());
				node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("header", NODETYPE_HEADER, NULL, node_program, node_id, node_semi, NULL, NULL, NULL);
			}
		;

declarations	:	constdefs typedefs vardefs { 
						// printf("declarations → constdefs typedefs vardefs\n");
						$$ = make_node("declarations", NODETYPE_DECLARATIONS, NULL, $1, $2, $3, NULL, NULL, NULL);
					}
				;

constdefs	:	T_CONST constant_defs SEMI { 
					// printf("constdefs → T_CONST constant_defs SEMI\n"); 
					$$ = make_node("constdefs", NODETYPE_CONSTDEFS, NULL, node_const, $2, node_semi, NULL, NULL, NULL);
									}
			|	{
					// printf("CONSTDEFS → ε\n");
					$$ = NULL;
									}
			;

constant_defs	:	constant_defs SEMI ID EQU expression { 
						// printf("constant_defs → constant_defs SEMI ID EQU expression\n"); 
						symbol* symbol_id = new_symbol(pop_yytext_stack());
						node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
						$$ = make_node("constant_defs", NODETYPE_CONSTANT_DEFS, NULL, $1, node_semi, node_id, node_equ, $5, NULL);
											}
				| 	ID EQU expression {
						// printf("constant_defs → ID EQU expression\n"); 
						symbol* symbol_id = new_symbol(pop_yytext_stack());
						node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
						$$ = make_node("constant_defs", NODETYPE_CONSTANT_DEFS, NULL, node_id, node_equ, $3, NULL, NULL, NULL);
											}
				;

expression	:	expression RELOP_NE expression { 
					// printf("expression → expression RELOP expression\n"); 
					$$ = make_node("expression_relop_ne", NODETYPE_EXPRESSION_RELOP_NE, NULL, $1, node_relop_ne, $3, NULL, NULL, NULL);
									}
			| 	expression RELOP_GE expression { 
					// printf("expression → expression RELOP expression\n"); 
					$$ = make_node("expression_relop_ge", NODETYPE_EXPRESSION_RELOP_GE, NULL, $1, node_relop_ge, $3, NULL, NULL, NULL);
									}
			|	expression RELOP_LE expression { 
					// printf("expression → expression RELOP expression\n"); 
					$$ = make_node("expression_relop_le", NODETYPE_EXPRESSION_RELOP_LE, NULL, $1, node_relop_le, $3, NULL, NULL, NULL);
									}
			|	expression RELOP_LT expression { 
					// printf("expression → expression RELOP expression\n"); 
					$$ = make_node("expression_relop_lt", NODETYPE_EXPRESSION_RELOP_LT, NULL, $1, node_relop_lt, $3, NULL, NULL, NULL);
									}
			|	expression RELOP_GT expression { 
					// printf("expression → expression RELOP expression\n"); 
					$$ = make_node("expression_relop_gt", NODETYPE_EXPRESSION_RELOP_GT, NULL, $1, node_relop_gt, $3, NULL, NULL, NULL);
									}
			|	expression EQU expression { 
					// printf("expression → expression EQU expression\n");
					$$ = make_node("expression_equ", NODETYPE_EXPRESSION_EQU, NULL, $1, node_equ, $3, NULL, NULL, NULL);
									}
			|	expression INOP expression { 
					// printf("expression → expression INOP expression\n"); 
					$$ = make_node("expression_inop", NODETYPE_EXPRESSION_INOP, NULL, $1, node_in, $3, NULL, NULL, NULL);
									}
			|	expression OROP expression { 
					// printf("expression → expression OROP expression\n"); 
					$$ = make_node("expression_orop", NODETYPE_EXPRESSION_OROP, NULL, $1, node_or, $3, NULL, NULL, NULL);
									}
			|	expression ADDOP_ADD expression	{ 
					// printf("expression → expression ADDOP expression\n");
					$$ = make_node("expression_addop_add", NODETYPE_EXPRESSION_ADDOP_ADD, NULL, $1, node_addop_add, $3, NULL, NULL, NULL);
									}
			|	expression ADDOP_SUB expression	{ 
					// printf("expression → expression ADDOP expression\n");
					$$ = make_node("expression_addop_sub", NODETYPE_EXPRESSION_ADDOP_SUB, NULL, $1, node_addop_sub, $3, NULL, NULL, NULL);
									}
			|	expression MULDIVANDOP_MUL expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					$$ = make_node("expression_muldivandop_mul", NODETYPE_EXPRESSION_MULDIVANDOP_MUL, NULL, $1, node_muldivandop_mul, $3, NULL, NULL, NULL);
									}
			|	expression MULDIVANDOP_DIV expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					$$ = make_node("expression_muldivandop_div", NODETYPE_EXPRESSION_MULDIVANDOP_DIV, NULL, $1, node_muldivandop_div, $3, NULL, NULL, NULL);
									}
			|	expression MULDIVANDOP_DIV_E expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					$$ = make_node("expression_muldivandop_div_e", NODETYPE_EXPRESSION_MULDIVANDOP_DIV_E, NULL, $1, node_muldivandop_div_e, $3, NULL, NULL, NULL);
									}
			|	expression MULDIVANDOP_MOD expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					$$ = make_node("expression", NODETYPE_EXPRESSION, NULL, $1, node_muldivandop_mod, $3, NULL, NULL, NULL);
									}
			|	expression MULDIVANDOP_AND expression { 
					// printf("expression → expression MULDIVANDOP expression\n");
					$$ = make_node("expression_muldivandop_and", NODETYPE_EXPRESSION_MULDIVANDOP_AND, NULL, $1, node_muldivandop_and, $3, NULL, NULL, NULL);
									}
			|	ADDOP_ADD expression { 
					// printf("expression → ADDOP expression\n");
					$$ = make_node("expression_addop_add_unary", NODETYPE_EXPRESSION_ADDOP_ADD_UNARY, NULL, node_addop_add, $2, NULL, NULL, NULL, NULL);
									}
			|	ADDOP_SUB expression { 
					// printf("expression → ADDOP expression\n");
					$$ = make_node("expression_addop_sub_unary", NODETYPE_EXPRESSION_ADDOP_SUB_UNARY, NULL, node_addop_sub, $2, NULL, NULL, NULL, NULL);
									}
			|	NOTOP expression {
					// printf("expression → NOTOP expression\n"); 
					$$ = make_node("expression_notop", NODETYPE_EXPRESSION_NOTOP, NULL, node_not, $2, NULL, NULL, NULL, NULL);
									}
			|	variable { 
					// printf("expression → variable\n"); 
					$$ = make_node("expression_variable", NODETYPE_EXPRESSION, NULL, $1, NULL, NULL, NULL, NULL, NULL);
									}
			|	ID LPAREN expressions RPAREN { 
					// printf("expression → ID LPAREN expressions RPAREN\n"); 
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("expression_id_paren", NODETYPE_EXPRESSION_ID_PAREN, NULL, node_id, node_lparen, $3, node_rparen, NULL, NULL);
									}
			|	constant { 
					// printf("expression → constant\n"); 
					$$ = make_node("expression_constant", NODETYPE_EXPRESSION, NULL, $1, NULL, NULL, NULL, NULL, NULL);
									}
			|	LPAREN expression RPAREN { 
					// printf("expression → LPAREN expression RPAREN\n");
					$$ = make_node("expression_paren", NODETYPE_EXPRESSION_PAREN, NULL, node_lparen, $2, node_rparen, NULL, NULL, NULL);
									}
			|	setexpression {
					// printf("expression → setexpression\n"); 
					$$ = make_node("expression", NODETYPE_EXPRESSION, NULL, $1, NULL, NULL, NULL, NULL, NULL);
									}
			;	


variable	:	ID { 
					// printf("variable → ID\n");
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("variable", NODETYPE_VARIABLE, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
									}
			|	variable DOT ID { 
					// printf("variable → variable DOT ID\n"); 
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("variable", NODETYPE_VARIABLE, NULL, $1, node_dot, node_id, NULL, NULL, NULL);
									}
			|	variable LBRACK expressions RBRACK { 
					// printf("variable → variable LBRACK expressions RBRACK\n"); 
					$$ = make_node("variable", NODETYPE_VARIABLE, NULL, $1, node_lbrack, $3, node_rbrack, NULL, NULL);
									}
			;

expressions	:	expressions COMMA expression { 
					// printf("expressions → expressions COMMA expression\n"); 
					$$ = make_node("expressions", NODETYPE_EXPRESSIONS, NULL, $1, node_comma, $3, NULL, NULL, NULL);
									}
			|	expression { 
					// printf("expressions → expression\n"); 
					$$ = make_node("expressions", NODETYPE_EXPRESSIONS, NULL, $1, NULL, NULL, NULL, NULL, NULL);
									}
			;

constant 	:	ICONST { 
					// printf("constant → ICONST\n");
					symbol* symbol_iconst = new_symbol(pop_yytext_stack());
					node* node_iconst = make_node("iconst", NODETYPE_ICONST, symbol_iconst, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_iconst", NODETYPE_CONSTANT, NULL, node_iconst, NULL, NULL, NULL, NULL, NULL);
									}
			| 	RCONST_REAL { 
					// printf("constant → RCONST\n"); 
					symbol* symbol_rconst_real = new_symbol(pop_yytext_stack());
					node* node_rconst_real = make_node("rconst_real", NODETYPE_RCONST_REAL, symbol_rconst_real, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_rconst_real", NODETYPE_CONSTANT, NULL, node_rconst_real, NULL, NULL, NULL, NULL, NULL);
									}
			| 	RCONST_INT { 
					// printf("constant → RCONST\n"); 
					symbol* symbol_rconst_int = new_symbol(pop_yytext_stack());
					node* node_rconst_int = make_node("rconst_int", NODETYPE_RCONST_INT, symbol_rconst_int, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_rconst_int", NODETYPE_CONSTANT, NULL, node_rconst_int, NULL, NULL, NULL, NULL, NULL);
									}
			| 	RCONST_HEX { 
					// printf("constant → RCONST\n");
					symbol* symbol_rconst_hex = new_symbol(pop_yytext_stack());
					node* node_rconst_hex = make_node("rconst_hex", NODETYPE_RCONST_HEX, symbol_rconst_hex, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_rconst_hex", NODETYPE_CONSTANT, NULL, node_rconst_hex, NULL, NULL, NULL, NULL, NULL);
									}
			| 	RCONST_BIN { 
					// printf("constant → RCONST\n"); 
					symbol* symbol_rconst_bin = new_symbol(pop_yytext_stack());
					node* node_rconst_bin = make_node("rconst_bin", NODETYPE_RCONST_BIN, symbol_rconst_bin, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_rconst_bin", NODETYPE_CONSTANT, NULL, node_rconst_bin, NULL, NULL, NULL, NULL, NULL);
									}
			| 	BCONST { 
					// printf("constant → BCONST\n"); 
					symbol* symbol_bconst = new_symbol(pop_yytext_stack());
					node* node_bconst = make_node("bconst", NODETYPE_BCONST, symbol_bconst, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_bconst", NODETYPE_CONSTANT, NULL, node_bconst, NULL, NULL, NULL, NULL, NULL);
									}
			| 	CCONST { 
					// printf("constant → CCONST\n"); 
					symbol* symbol_cconst = new_symbol(pop_yytext_stack());
					node* node_cconst = make_node("cconst", NODETYPE_CCONST, symbol_cconst, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("constant_cconst", NODETYPE_CONSTANT, NULL, node_cconst, NULL, NULL, NULL, NULL, NULL);
									}
			;

setexpression	: 	LBRACK elexpressions RBRACK { 
						// printf("setexpression → LBRACK elexpressions RBRACK\n"); 
						$$ = make_node("setexpression", NODETYPE_SETEXPRESSION, NULL, node_lbrack, $2, node_rbrack, NULL, NULL, NULL);
											}
				| 	LBRACK RBRACK { 
						// printf("setexpression → LBRACK RBRACK\n"); 
						$$ = make_node("setexpression", NODETYPE_SETEXPRESSION, NULL, node_lbrack, node_rbrack, NULL, NULL, NULL, NULL);
											}
				;

elexpressions	:	elexpressions COMMA elexpression { 
						// printf("elexpressions → elexpressions COMMA elexpression\n"); 
						$$ = make_node("elexpressions", NODETYPE_ELEXPRESSIONS, NULL, $1, node_comma, $3, NULL, NULL, NULL);
											}
				|	elexpression {
						// printf("elexpressions → elexpression\n"); 
						$$ = make_node("elexpressions", NODETYPE_ELEXPRESSIONS, NULL, $1, NULL, NULL, NULL, NULL, NULL);
											}
				;

elexpression	:	expression DOTDOT expression { 
						// printf("elexpression → expression DOTDOT expression\n"); 
						$$ = make_node("elexpression", NODETYPE_ELEXPRESSION, NULL, $1, node_dotdot, $3, NULL, NULL, NULL);
											}
				|	expression { 
						// printf("elexpression → expression\n"); 
						$$ = make_node("elexpression", NODETYPE_ELEXPRESSION, NULL, $1, NULL, NULL, NULL, NULL, NULL);
											}
				;

typedefs	:	T_TYPE type_defs SEMI	{
					// printf("typedefs → T_TYPE type_defs SEMI\n");
					$$ = make_node("typedefs", NODETYPE_TYPEDEFS, NULL, node_type, $2, node_semi, NULL, NULL, NULL);
									}
			| 	{
					// printf("typedefs → ε\n"); 
					$$ = NULL;
									}
			;

type_defs	:	type_defs SEMI ID EQU type_def { 
					// printf("type_defs → type_defs SEMI ID EQU type_def\n"); 
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("type_defs", NODETYPE_TYPE_DEFS, NULL, $1, node_semi, node_id, node_equ, $5, NULL);
									}
			| 	ID EQU type_def { 
					// printf("type_defs → ID EQU type_def\n"); 
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("type_defs", NODETYPE_TYPE_DEFS, NULL, node_id, node_equ, $3, NULL, NULL, NULL);
									}
			;

type_def	:	T_ARRAY LBRACK dims RBRACK T_OF typename { 
					// printf("type_def → T_ARRAY LBRACK dims RBRACK T_OF typename\n"); 
					$$ = make_node("type_def", NODETYPE_TYPE_DEF, NULL, node_array, node_lbrack, $3, node_rbrack, node_of, $6);
									}
			|	T_SET T_OF typename { 
					// printf("type_def → T_SET T_OF typename\n"); 
					$$ = make_node("type_def", NODETYPE_TYPE_DEF, NULL, node_set, node_of, $3, NULL, NULL, NULL);
									}
			|	T_RECORD fields T_END { 
					// printf("type_def → T_RECORD fields T_END\n"); 
					$$ = make_node("type_def", NODETYPE_TYPE_DEF, NULL, node_record, $2, node_end, NULL, NULL, NULL);
									}
			|	LPAREN identifiers RPAREN { 
					// printf("type_def → LPAREN identifiers RPAREN\n"); 
					$$ = make_node("type_def", NODETYPE_TYPE_DEF, NULL, node_lparen, $2, node_rparen, NULL, NULL, NULL);
									}
			|	limit DOTDOT limit { 
					// printf("type_def → limit DOTDOT limit\n"); 
					$$ = make_node("type_def", NODETYPE_TYPE_DEF, NULL, $1, node_dotdot, $3, NULL, NULL, NULL);
									}
			;

dims	:	dims COMMA limits { 
				// printf("dims → dims COMMA limits\n"); 
				$$ = make_node("dims", NODETYPE_DIMS, NULL, $1, node_comma, $3, NULL, NULL, NULL);
							}
		| 	limits { 
				// printf("dims → limits\n"); 
				$$ = make_node("dims", NODETYPE_DIMS, NULL, $1, NULL, NULL, NULL, NULL, NULL);
							}
		;

limits	:	limit DOTDOT limit { 
				// printf("limits → limit DOTDOT limit\n"); 
				$$ = make_node("limits", NODETYPE_LIMITS, NULL, $1, node_dotdot, $3, NULL, NULL, NULL);
							}
		|	ID { 
				// printf("limits → ID\n"); 
				symbol* symbol_id = new_symbol(pop_yytext_stack());
				node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limits", NODETYPE_LIMITS, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
							}
		;

limit	:	ADDOP_ADD ICONST { 
				// printf("limit → ADDOP ICONST\n");
				symbol* symbol_iconst = new_symbol(pop_yytext_stack());
				node* node_iconst = make_node("iconst", NODETYPE_ICONST, symbol_iconst, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT_ADDOP_ADD_ICONST, NULL, node_addop_add, node_iconst, NULL, NULL, NULL, NULL);
							}
		|	ADDOP_SUB ICONST { 
				// printf("limit → ADDOP ICONST\n"); 
				symbol* symbol_iconst = new_symbol(pop_yytext_stack());
				node* node_iconst = make_node("iconst", NODETYPE_LIMIT_ADDOP_SUB_ICONST, symbol_iconst, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT_ADDOP_SUB_ICONST, NULL, node_addop_sub, node_iconst, NULL, NULL, NULL, NULL);
											}
		| 	ADDOP_ADD ID { 
				// printf("limit → ADDOP ID\n"); 
				symbol* symbol_id = new_symbol(pop_yytext_stack());
				node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT_ADDOP_ADD_ID, NULL, node_addop_add, node_id, NULL, NULL, NULL, NULL);
							}
		| 	ADDOP_SUB ID { 
				// printf("limit → ADDOP ID\n");
								symbol* symbol_id = new_symbol(pop_yytext_stack());
				node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT, NULL, node_addop_sub, node_id, NULL, NULL, NULL, NULL);
							}
		| 	ICONST { 
				// printf("limit → ICONST\n"); 
				symbol* symbol_iconst = new_symbol(pop_yytext_stack());
				node* node_iconst = make_node("iconst", NODETYPE_ICONST, symbol_iconst, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT, NULL, node_iconst, NULL, NULL, NULL, NULL, NULL);
			}
		| 	CCONST { 
				// printf("limit → CCONST\n"); 
								symbol* symbol_cconst = new_symbol(pop_yytext_stack());
				node* node_cconst = make_node("cconst", NODETYPE_CCONST, symbol_cconst, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT, NULL, node_cconst, NULL, NULL, NULL, NULL, NULL);
							}
		| 	BCONST { 
				// printf("limit → BCONST\n");
								symbol* symbol_bconst = new_symbol(pop_yytext_stack());
				node* node_bconst = make_node("bconst", NODETYPE_BCONST, symbol_bconst, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT, NULL, node_bconst, NULL, NULL, NULL, NULL, NULL);
							}
		| 	ID { 
				// printf("limit → ID\n");
								symbol* symbol_id = new_symbol(pop_yytext_stack());
				node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
				$$ = make_node("limit", NODETYPE_LIMIT, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
							}
		;

typename	:	standard_type { 
					// printf("typename → standard_type\n");
					$$ = make_node("typename", NODETYPE_TYPENAME, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	ID { 
					// printf("typename → ID\n"); 
					symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("typename", NODETYPE_TYPENAME, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
				}
			;

standard_type	:	T_INTEGER { 
						// printf("standard_type → T_INTEGER\n"); 
						$$ = make_node("standard_type", NODETYPE_STANDARD_TYPE, NULL, node_integer, NULL, NULL, NULL, NULL, NULL);
					}
				| 	T_REAL { 
						// printf("standard_type → T_REAL\n"); 
						$$ = make_node("standard_type", NODETYPE_STANDARD_TYPE, NULL, node_real, NULL, NULL, NULL, NULL, NULL);
					}
				| 	T_BOOLEAN { 
						// printf("standard_type → T_BOOLEAN\n"); 
						$$ = make_node("standard_type", NODETYPE_STANDARD_TYPE, NULL, node_boolean, NULL, NULL, NULL, NULL, NULL);
					}
				| 	T_CHAR { 
						// printf("standard_type → T_CHAR\n"); 
						$$ = make_node("standard_type", NODETYPE_STANDARD_TYPE, NULL, node_char, NULL, NULL, NULL, NULL, NULL);
					}
				;

fields	:	fields SEMI field { 
				// printf("fields → fields SEMI field\n"); 
				$$ = make_node("fields", NODETYPE_FIELDS, NULL, $1, node_semi, $3, NULL, NULL, NULL);
			}
		| 	field { 
				// printf("fields → field\n"); 
				$$ = make_node("fields", NODETYPE_FIELDS, NULL, $1, NULL, NULL, NULL, NULL, NULL);
			}
		;

field	:	identifiers COLON typename { 
				// printf("field → identifiers COLON typename\n"); 
				$$ = make_node("field", NODETYPE_FIELD, NULL, $1, node_colon, $3, NULL, NULL, NULL);
			}
		;

identifiers	:	identifiers COMMA ID { 
					// printf("identifiers → identifiers COMMA ID\n"); 
										symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("identifiers", NODETYPE_IDENTIFIERS, NULL, $1, node_comma, node_id, NULL, NULL, NULL);
									}
			|	ID { 
					// printf("identifiers → ID\n"); 
										symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("identifiers", NODETYPE_IDENTIFIERS, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
									}
			;

vardefs	:	T_VAR variable_defs SEMI { 
				// printf("vardefs → T_VAR variable_defs SEMI\n"); 
				$$ = make_node("vardefs", NODETYPE_VARDEFS, NULL, node_var, $2, node_semi, NULL, NULL, NULL);
			}
		| 	{ 
				// printf("vardefs → ε\n");
				$$ = NULL;
			}
		;

variable_defs	:	variable_defs SEMI identifiers COLON typename { 
						// printf("variable_defs → variable_defs SEMI identifiers COLON typename\n"); 
						$$ = make_node("variable_defs", NODETYPE_VARIABLE_DEFS, NULL, $1, node_semi, $3, node_colon, $5, NULL);
					}
				| 	identifiers COLON typename {
						// printf("variable_defs → identifiers COLON typename\n"); 
						$$ = make_node("variable_defs", NODETYPE_VARIABLE_DEFS, NULL, $1, node_colon, $3, NULL, NULL, NULL);
					}
				;

subprograms	:	subprograms subprogram SEMI { 
					// printf("subprograms → subprograms subprogram SEMI\n");
					$$ = make_node("subprograms", NODETYPE_SUBPROGRAMS, NULL, $1, $2, node_semi, NULL, NULL, NULL);
				}
			| 	{
					// printf("subprograms → ε\n");
					$$ = NULL;
				}
			;

subprogram	:	sub_header SEMI T_FORWARD { 
					// printf("subprogram → sub_header SEMI T_FORWARD\n"); 
					$$ = make_node("subprogram", NODETYPE_SUBPROGRAM, NULL, $1, node_semi, node_forward, NULL, NULL, NULL);
				}
			| 	sub_header SEMI declarations subprograms comp_statement { 
					// printf("subprogram → sub_header SEMI declarations subprograms comp_statement\n"); 
					$$ = make_node("subprogram", NODETYPE_SUBPROGRAM, NULL, $1, node_semi, $3, $4, $5, NULL);
				}
			;

sub_header	:	T_FUNCTION ID formal_parameters COLON standard_type { 
					// printf("sub_header → T_FUNCTION ID formal_parameters COLON standard_type\n"); 
										symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("sub_header", NODETYPE_SUB_HEADER, NULL, node_function, node_id, $3, node_colon, $5, NULL);
									}
			|	T_PROCEDURE ID formal_parameters { 
					// printf("sub_header → T_PROCEDURE ID formal_parameters\n"); 
										symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("sub_header", NODETYPE_SUB_HEADER, NULL, node_procedure, node_id, $3, NULL, NULL, NULL);
									}
			|	T_FUNCTION ID { 
					// printf("sub_header → T_FUNCTION ID\n"); 
										symbol* symbol_id = new_symbol(pop_yytext_stack());
					node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("sub_header", NODETYPE_SUB_HEADER, NULL, node_function, node_id, NULL, NULL, NULL, NULL);
									}
			;

formal_parameters	:	LPAREN parameter_list RPAREN { 
							// printf("formal_parameters → LPAREN parameter_list RPAREN\n"); 
							$$ = make_node("formal_parameters", NODETYPE_FORMAL_PARAMETERS, NULL, node_lparen, $2, node_rparen, NULL, NULL, NULL);
						}
					| 	{ 
							// printf("formal_parameters → ε\n"); 
							$$ = NULL;
						}
					;

parameter_list	:	parameter_list SEMI pass identifiers COLON typename { 
						// printf("parameter_list → parameter_list SEMI pass identifiers COLON typename\n"); 
						$$ = make_node("parameter_list", NODETYPE_PARAMETER_LIST, NULL, $1, node_semi, $3, $4, node_colon, $6);
					}
				| 	pass identifiers COLON typename { 
						// printf("parameter_list → pass identifiers COLON typename\n"); 
						$$ = make_node("parameter_list", NODETYPE_PARAMETER_LIST, NULL, $1, $2, node_colon, $4, NULL, NULL);
					}
				;

pass	:	T_VAR { 
				// printf("pass → T_VAR\n"); 
				$$ = make_node("pass", NODETYPE_PASS, NULL, node_var, NULL, NULL, NULL, NULL, NULL);
			}
		| 	{ 
				// printf("pass → ε\n"); 
				$$ = NULL;
			}
		;

comp_statement	:	T_BEGIN statements T_END { 
						// printf("comp_statement → T_BEGIN statements T_END\n"); 
						$$ = make_node("comp_statement", NODETYPE_COMP_STATEMENT, NULL, node_begin, $2, node_end, NULL, NULL, NULL);
					}
				;

statements	:	statements SEMI statement { 
					// printf("statements → statements SEMI statement\n"); 
					$$ = make_node("statements", NODETYPE_STATEMENTS, NULL, $1, node_semi, $3, NULL, NULL, NULL);
				}
			| 	statement { 
					// printf("statements → statement\n"); 
					$$ = make_node("statements", NODETYPE_STATEMENTS, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			;

statement	:	assignment { 
					// printf("statement → assignment\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	if_statement { 
					// printf("statement → if_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	while_statement { 
					// printf("statement → while_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	for_statement { 
					// printf("statement → for_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	with_statement { 
					// printf("statement → with_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	subprogram_call { 
					// printf("statement → subprogram_call\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	io_statement { 
					// printf("statement → io_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	comp_statement { 
					// printf("statement → comp_statement\n"); 
					$$ = make_node("statement", NODETYPE_STATEMENT, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			|	{ 
					// printf("statement → ε\n"); 
					$$ = NULL;
				}
			;

assignment	:	variable ASSIGN expression { 
					// printf("assignment → variable ASSIGN expression\n"); 
					$$ = make_node("assignment", NODETYPE_ASSIGNMENT, NULL, $1, node_assign, $3, NULL, NULL, NULL);
				}
			| 	variable ASSIGN STRING { 
					// printf("assignment → variable ASSIGN STRING\n"); 
										symbol* symbol_string = new_symbol(pop_yytext_stack());
					node* node_string = make_node("string", NODETYPE_STRING, symbol_string, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("assignment", NODETYPE_ASSIGNMENT, NULL, $1, node_assign, node_string, NULL, NULL, NULL);
									}
			;

if_statement	:	T_IF expression T_THEN statement {
						// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
						$$ = make_node("if_statement", NODETYPE_IF_STATEMENT, NULL, node_if, $2, node_then, $4, NULL, NULL);
					}
					| T_IF expression T_THEN statement T_ELSE statement {
						// printf("if_statement → T_IF expression T_THEN statement if_tail\n"); 
						$$ = make_node("if_statement", NODETYPE_IF_STATEMENT, NULL, node_if, $2, node_then, $4, node_else, $6);
					}
				;

while_statement	:	T_WHILE expression T_DO statement { 
						// printf("while_statement → T_WHILE expression T_DO statement\n"); 
						$$ = make_node("while_statement", NODETYPE_WHILE_STATEMENT, NULL, node_while, $2, node_do, $4, NULL, NULL);
					}
				;

for_statement	:	T_FOR ID ASSIGN iter_space T_DO statement {
						// printf("for_statement → T_FOR ID ASSIGN iter_space T_DO statement\n");
												symbol* symbol_id = new_symbol(pop_yytext_stack());
						node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
						$$ = make_node("for_statement", NODETYPE_FOR_STATEMENT, NULL, node_for, node_id, node_assign, $4, node_do, $6);
											}
				;

iter_space	:	expression T_TO expression { 
					// printf("iter_space → expression T_TO expression\n");
					$$ = make_node("iter_space", NODETYPE_ITER_SPACE, NULL, $1, node_to, $3, NULL, NULL, NULL);
				}
			| 	expression T_DOWNTO expression { 
					// printf("iter_space → expression T_DOWNTO expression\n"); 
					$$ = make_node("iter_space", NODETYPE_ITER_SPACE, NULL, $1, node_downto, $3, NULL, NULL, NULL);
				}
			;


with_statement	:	T_WITH variable T_DO statement { 
						// printf("with_statement → T_WITH variable T_DO statement\n"); 
						$$ = make_node("with_statement", NODETYPE_WITH_STATEMENT, NULL, node_with, $2, node_do, $4, NULL, NULL);
					}
				;

subprogram_call	:	ID {
						//  printf("subprogram_call → ID\n");
						symbol* symbol_id = new_symbol(pop_yytext_stack());
						node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
						$$ = make_node("subprogram_call", NODETYPE_SUBPROGRAM_CALL, NULL, node_id, NULL, NULL, NULL, NULL, NULL);
											}
				| 	ID LPAREN expressions RPAREN { 
						// printf("subprogram_call → ID LPAREN expressions RPAREN\n");
						symbol* symbol_id = new_symbol(pop_yytext_stack());
						node* node_id = make_node("ID", NODETYPE_ID, symbol_id, NULL, NULL, NULL, NULL, NULL, NULL);
						$$ = make_node("subprogram_call", NODETYPE_SUBPROGRAM_CALL, NULL, node_id, node_lparen, $3, node_rparen, NULL, NULL);
					}
				;

io_statement	:	T_READ LPAREN read_list RPAREN { 
						// printf("io_statement → T_READ LPAREN read_list RPAREN\n"); 
						$$ = make_node("io_statement", NODETYPE_IO_STATEMENT, NULL, node_read, node_lparen, $3, node_rparen, NULL, NULL);
					}
				| 	T_WRITE LPAREN write_list RPAREN { 
						// printf("io_statement → T_WRITE LPAREN write_list RPAREN\n"); 
						$$ = make_node("io_statement", NODETYPE_IO_STATEMENT, NULL, node_write, node_lparen, $3, node_rparen, NULL, NULL);
					}
				;

read_list	:	read_list COMMA read_item { 
					// printf("read_list → read_list COMMA read_item\n"); 
					$$ = make_node("read_list", NODETYPE_READ_LIST, NULL, $1, node_comma, $3, NULL, NULL, NULL);
				}
			| 	read_item { 
					// printf("read_list → read_item\n"); 
					$$ = make_node("read_list", NODETYPE_READ_LIST, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			;

read_item	:	variable { 
					// printf("read_item → variable\n"); 
					$$ = make_node("read_item", NODETYPE_READ_ITEM, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			;

write_list	:	write_list COMMA write_item { 
					// printf("write_list → write_list COMMA write_item\n");
					$$ = make_node("write_list", NODETYPE_WRITE_LIST, NULL, $1, node_comma, $3, NULL, NULL, NULL);
				}
			|	write_item { 
					// printf("write_list → write_item\n"); 
					$$ = make_node("write_list", NODETYPE_WRITE_LIST, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			;

write_item	:	expression { 
					// printf("write_item → expression\n"); 
					$$ = make_node("write_item", NODETYPE_WRITE_ITEM, NULL, $1, NULL, NULL, NULL, NULL, NULL);
				}
			| 	STRING { 
					// printf("write_item → STRING\n"); 
					symbol* symbol_string = new_symbol(pop_yytext_stack());
					node* node_string = make_node("string", NODETYPE_STRING, symbol_string, NULL, NULL, NULL, NULL, NULL, NULL);
					$$ = make_node("write_item", NODETYPE_WRITE_ITEM, NULL, node_string, NULL, NULL, NULL, NULL, NULL);
				}
			;
%%

int main () {
	create_node_types();
	Symbol_free = NULL;

	yytext_stack = (yytext_stack_struct *) malloc(sizeof(yytext_stack_struct));
	int ret = yyparse();
	printf("\n--------------------\nAbstract Syntax Tree\n--------------------\n\n");
	preorder_tree_traversal(ast_tree_root, 0);
	printf("\n");
  	return ret;
}

