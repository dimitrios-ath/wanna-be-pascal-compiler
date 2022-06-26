#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "defs.h"

char* pop_yytext_stack() {
	char* ret = yytext_stack->stack[yytext_stack->size-1];
	yytext_stack->stack[--yytext_stack->size] = NULL;
	return ret;
}

void push_yytext_stack(char* yytext) {
	yytext_stack->stack[yytext_stack->size++] = strdup(yytext);
}

// void debug_yytext() {
// 	printf("Number of used slots = %d\n\n", yytexts->slots);
// 	for (int i=0; i<yytexts->slots; i++)
// 		printf("%s\n", yytexts->yytext[i]);
// 	printf("\n");
// }

void print_tabs(int depth) {
	for (int i=0; i<depth; i++)
			printf("‣   ");
}

void preorder_tree_traversal(node* node, int depth) {
	if (!node)
		return;
	else {
		print_tabs(depth);
		if(node->symbol) {
			printf("%s = %s\n", node->name, node->symbol->name);
		}
		else {
			printf("%s\n", node->name);
		}
	}

	if (node->nodes[0])
		preorder_tree_traversal(node->nodes[0], depth+1);
	if (node->nodes[1])
		preorder_tree_traversal(node->nodes[1], depth+1);
	if (node->nodes[2])
		preorder_tree_traversal(node->nodes[2], depth+1);
	if (node->nodes[3])
		preorder_tree_traversal(node->nodes[3], depth+1);
	if (node->nodes[4])
		preorder_tree_traversal(node->nodes[4], depth+1);
	if (node->nodes[5])
		preorder_tree_traversal(node->nodes[5], depth+1);
}

node* make_node(char* node_name, int node_type, symbol *symbol, node* node_0, node* node_1, node* node_2, node* node_3, node* node_4, node* node_5)
{  
	node* p;

	p = (node *) malloc(sizeof(node));
	if(!p)
	{
		printf("Out of memory\n");
		exit(1);
	}
	else
	{
		p->type = node_type;
		p->name = strdup(node_name);
		p->symbol = symbol;
		p->nodes[0] = node_0;
		p->nodes[1] = node_1;
		p->nodes[2] = node_2;
		p->nodes[3] = node_3;
		p->nodes[4] = node_4;
		p->nodes[5] = node_5;
		return(p);
   }
}

symbol *new_symbol(char *name)
{  symbol *symbp;

   if(!Symbol_free)
      symbp=(symbol *)malloc(sizeof(symbol));
   else
   {
      symbp=Symbol_free;
      Symbol_free=Symbol_free->Next_in_Cross_Link;
   }
   memset(symbp,0,sizeof(symbol));
   strncpy((char*) symbp->name,name,(strlen(name)>NAME_MAX)?NAME_MAX:strlen(name));
   symbp->timi=0;
   symbp->disposable=FALSE;
   symbp->lvalue=TRUE;
   symbp->Next_in_Cross_Link=NULL;
   symbp->NextSymbol=NULL;
   symbp->PrevSymbol=NULL;
   return(symbp);
}

void create_node_types() {
	node_program = make_node("program", NODETYPE_KEYWORD_PROGRAM, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_const = make_node("const", NODETYPE_KEYWORD_CONST, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_type = make_node("type", NODETYPE_KEYWORD_TYPE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_array = make_node("array", NODETYPE_KEYWORD_ARRAY, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_set = make_node("set", NODETYPE_KEYWORD_SET, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_of = make_node("of", NODETYPE_KEYWORD_OF, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_record = make_node("record", NODETYPE_KEYWORD_RECORD, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_var = make_node("var", NODETYPE_KEYWORD_VAR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_forward = make_node("forward", NODETYPE_KEYWORD_FORWARD, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_function = make_node("function", NODETYPE_KEYWORD_FUNCTION, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_procedure = make_node("procedure", NODETYPE_KEYWORD_PROCEDURE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_integer = make_node("integer", NODETYPE_KEYWORD_INTEGER, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_real = make_node("real", NODETYPE_KEYWORD_REAL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_boolean = make_node("boolean", NODETYPE_KEYWORD_BOOLEAN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_char = make_node("char", NODETYPE_KEYWORD_CHAR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_begin = make_node("begin", NODETYPE_KEYWORD_BEGIN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_end = make_node("end", NODETYPE_KEYWORD_END, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_if = make_node("if", NODETYPE_KEYWORD_IF, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_then = make_node("then", NODETYPE_KEYWORD_THEN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_else = make_node("else", NODETYPE_KEYWORD_ELSE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_while = make_node("while", NODETYPE_KEYWORD_WHILE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_do = make_node("do", NODETYPE_KEYWORD_DO, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_for = make_node("for", NODETYPE_KEYWORD_FOR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_downto = make_node("downto", NODETYPE_KEYWORD_DOWNTO, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_to = make_node("to", NODETYPE_KEYWORD_TO, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_with = make_node("with", NODETYPE_KEYWORD_WITH, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_read = make_node("read", NODETYPE_KEYWORD_READ, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_write = make_node("write", NODETYPE_KEYWORD_WRITE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_or = make_node("or", NODETYPE_KEYWORD_OR, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_not = make_node("not", NODETYPE_KEYWORD_NOT, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_in = make_node("in", NODETYPE_KEYWORD_IN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	
	node_lparen = make_node("(", NODETYPE_LPAREN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_rparen = make_node(")", NODETYPE_RPAREN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_semi = make_node(";", NODETYPE_SEMI, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_dot = make_node(".", NODETYPE_DOT, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_comma = make_node(",", NODETYPE_COMMA, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_equ = make_node("=", NODETYPE_EQU, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_colon = make_node(":", NODETYPE_COLON, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_lbrack = make_node("[", NODETYPE_LBRACK, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_rbrack = make_node("]", NODETYPE_RBRACK, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_assign = make_node(":=", NODETYPE_ASSIGN, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_dotdot = make_node("..", NODETYPE_DOTDOT, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

	node_addop_add = make_node("+", NODETYPE_EXPRESSION_ADDOP_ADD, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_addop_sub = make_node("-", NODETYPE_EXPRESSION_ADDOP_SUB, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_relop_ne = make_node("<>", NODETYPE_EXPRESSION_RELOP_NE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_relop_ge = make_node(">=", NODETYPE_EXPRESSION_RELOP_GE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_relop_le = make_node("<=", NODETYPE_EXPRESSION_RELOP_LE, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_relop_gt = make_node(">", NODETYPE_EXPRESSION_RELOP_GT, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_relop_lt = make_node("<", NODETYPE_EXPRESSION_RELOP_LT, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_muldivandop_mul = make_node("*", NODETYPE_EXPRESSION_MULDIVANDOP_MUL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_muldivandop_div = make_node("/", NODETYPE_EXPRESSION_MULDIVANDOP_DIV, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_muldivandop_div_e = make_node("div", NODETYPE_EXPRESSION_MULDIVANDOP_DIV_E, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_muldivandop_mod = make_node("mod", NODETYPE_EXPRESSION_MULDIVANDOP_MOD, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_muldivandop_and = make_node("and", NODETYPE_EXPRESSION_MULDIVANDOP_AND, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_addop_add = make_node("+", NODETYPE_EXPRESSION_ADDOP_ADD_UNARY, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
	node_addop_sub = make_node("-", NODETYPE_EXPRESSION_ADDOP_SUB_UNARY, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
}