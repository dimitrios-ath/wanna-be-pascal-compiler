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

void preorder_tree_traversal(node* node, int depth) {
	if (node) {
		for (int i=0; i<depth; i++)
			printf("|   ");
		switch (node->type) {
			case NODE_TYPE_PROGRAM:
				printf("header declarations subprograms comp_statement.\n");
				break;
			case NODE_TYPE_HEADER:
				printf("program %s;\n", node->symbol->name);
				break;
			case NODE_TYPE_DECLARATIONS:
				printf("constdefs typedefs vardefs\n");
				break;
			case NODE_TYPE_CONSTDEFS:
				printf("const constant_defs;\n");
				break;
			case NODE_TYPE_CONSTANT_DEFS_0:
				printf("constant_defs; %s = expression\n", node->symbol->name);
				break;
			case NODE_TYPE_CONSTANT_DEFS_1:
				printf("%s = expression\n", node->symbol->name);
				break;
			case NODE_TYPE_EXPRESSION_0:
				printf("expression <> expression\n");
				break;
			case NODE_TYPE_EXPRESSION_1:
				printf("expression >= expression\n");
				break;
			case NODE_TYPE_EXPRESSION_2:
				printf("expression <= expression\n");
				break;
			case NODE_TYPE_EXPRESSION_3:
				printf("expression < expression\n");
				break;
			case NODE_TYPE_EXPRESSION_4:
				printf("expression > expression\n");
				break;
			case NODE_TYPE_EXPRESSION_5:
				printf("expression = expression\n");
				break;
			case NODE_TYPE_EXPRESSION_6:
				printf("expression in expression\n");
				break;
			case NODE_TYPE_EXPRESSION_7:
				printf("expression or expression\n");
				break;
			case NODE_TYPE_EXPRESSION_8:
				printf("expression + expression\n");
				break;
			case NODE_TYPE_EXPRESSION_9:
				printf("expression - expression\n");
				break;
			case NODE_TYPE_EXPRESSION_10:
				printf("expression * expression\n");
				break;
			case NODE_TYPE_EXPRESSION_11:
				printf("expression / expression\n");
				break;
			case NODE_TYPE_EXPRESSION_12:
				printf("expression div expression\n");
				break;
			case NODE_TYPE_EXPRESSION_13:
				printf("expression mod expression\n");
				break;
			case NODE_TYPE_EXPRESSION_14:
				printf("expression and expression\n");
				break;
			case NODE_TYPE_EXPRESSION_15:
				printf("+ expression\n");
				break;
			case NODE_TYPE_EXPRESSION_16:
				printf("- expression\n");
				break;
			case NODE_TYPE_EXPRESSION_17:
				printf("not expression\n");
				break;
			case NODE_TYPE_EXPRESSION_18:
				printf("%s(expression)\n", node->symbol->name);
				break;
			case NODE_TYPE_EXPRESSION_19:
				printf("(expression)\n");
				break;
			case NODE_TYPE_VARIABLE_0:
				printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_VARIABLE_1:
				printf("variable.%s\n", node->symbol->name);
				break;
			case NODE_TYPE_VARIABLE_2:
				printf("variable[expression]\n");
				break;
			case NODE_TYPE_EXPRESSIONS:
				printf("expressions, expressions\n");
				break;
			case NODE_TYPE_CONSTANT_0:
			case NODE_TYPE_CONSTANT_1:
			case NODE_TYPE_CONSTANT_2:
			case NODE_TYPE_CONSTANT_3:
			case NODE_TYPE_CONSTANT_4:
			case NODE_TYPE_CONSTANT_5:
			case NODE_TYPE_CONSTANT_6:
				printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_SETEXPRESSION_0:
				printf("[elexpressions]\n");
				break;
			case NODE_TYPE_SETEXPRESSION_1:
				printf("[]\n");
				break;
			case NODE_TYPE_ELEXPRESSIONS:
				printf("elexpressions, elexpressions\n");
				break;
			case NODE_TYPE_ELEXPRESSION:
				printf("expression..expression\n");
				break;
			case NODE_TYPE_TYPEDEFS:
				printf("type type_defs;\n");
				break;
			case NODE_TYPE_TYPE_DEFS_0:
				printf("type_defs; %s = type_def\n", node->symbol->name);
				break;
			case NODE_TYPE_TYPE_DEFS_1:
				printf("%s = type_def\n", node->symbol->name);
				break;
			case NODE_TYPE_TYPE_DEF_0:
				printf("array[dims] of typename\n");
				break;
			case NODE_TYPE_TYPE_DEF_1:
				printf("set of typename\n");
				break;
			case NODE_TYPE_TYPE_DEF_2:
				printf("record fields end\n");
				break;
			case NODE_TYPE_TYPE_DEF_3:
				printf("(identifiers)\n");
				break;
			case NODE_TYPE_TYPE_DEF_4:
				printf("limit..limit\n");
				break;
			case NODE_TYPE_DIMS:
				printf("dims, limits\n");
				break;
			case NODE_TYPE_LIMITS_0:
				printf("limit..limit\n");
				break;
			case NODE_TYPE_LIMITS_1:
				printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_LIMIT_0:
			case NODE_TYPE_LIMIT_2:
				printf("+%s\n", node->symbol->name);
				break;
			case NODE_TYPE_LIMIT_1:
			case NODE_TYPE_LIMIT_3:
				printf("-%s\n", node->symbol->name);
				break;
			case NODE_TYPE_LIMIT_4:
			case NODE_TYPE_LIMIT_5:
			case NODE_TYPE_LIMIT_6:
			case NODE_TYPE_LIMIT_7:
			case NODE_TYPE_TYPENAME:
			case NODE_TYPE_IDENTIFIERS_1:
				printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_FIELDS_0:
				printf("fields; field\n");
				break;
			case NODE_TYPE_FIELDS_1:
				printf("field\n");
				break;
			case NODE_TYPE_FIELD:
				printf("identifiers: typename\n");
				break;
			case NODE_TYPE_IDENTIFIERS_0:
				printf("identifiers, %s\n", node->symbol->name);
				break;
			case NODE_TYPE_VARDEFS:
				printf("var variable_defs;\n");
				break;
			case NODE_TYPE_VARIABLE_DEFS_0:
				printf("variable_defs; identifiers: typename\n");
				break;
			case NODE_TYPE_VARIABLE_DEFS_1:
				printf("identifiers: typename\n");
				break;
			case NODE_TYPE_SUBPROGRAMS:
				printf("subprograms subprogram;\n");
				break;

			case NODE_TYPE_SUBPROGRAM_0:
				printf("sub_header; forward\n");
				break;
			case NODE_TYPE_SUBPROGRAM_1:
				printf("sub_header; declarations subprograms comp_statement\n");
				break;
			case NODE_TYPE_SUB_HEADER_0:
				printf("function %s formal_parameters: standard_type\n", node->symbol->name);
				break;
			case NODE_TYPE_SUB_HEADER_1:
				printf("procedure %s formal_parameters\n", node->symbol->name);
				break;
			case NODE_TYPE_SUB_HEADER_2:
				printf("function %s\n", node->symbol->name);
				break;
			case NODE_TYPE_FORMAL_PARAMETERS:
				printf("(parameter_list)\n");
				break;
			case NODE_TYPE_PARAMETER_LIST_0:
				printf("parameter_list; pass identifiers: typename\n");
				break;
			case NODE_TYPE_PARAMETER_LIST_1:
				printf("pass identifiers: typename\n");
				break;
			case NODE_TYPE_COMP_STATEMENT:
				printf("begin statements end\n");
				break;
			case NODE_TYPE_STATEMENTS:
				printf("statements; statement\n");
				break;
			case NODE_TYPE_ASSIGNMENT_0:
				printf("variable := expression\n");
				break;
			case NODE_TYPE_ASSIGNMENT_1:
				printf("variable := %s\n", node->symbol->name);
				break;
			case NODE_TYPE_IF_STATEMENT_0:
				printf("if expression then statement\n");
				break;
			case NODE_TYPE_IF_STATEMENT_1:
				printf("if expression then statement else statement\n");
				break;
			case NODE_TYPE_WHILE_STATEMENT:
				printf("while expression do statement\n");
				break;
			case NODE_TYPE_FOR_STATEMENT:
				printf("for %s := iter_space do statement\n", node->symbol->name);
				break;
			case NODE_TYPE_ITER_SPACE_0:
				printf("expression to expression\n");
				break;
			case NODE_TYPE_ITER_SPACE_1:
				printf("expression downto expression\n");
				break;
			case NODE_TYPE_WITH_STATEMENT:
				printf("with variable do statement\n");
				break;
			case NODE_TYPE_SUBPROGRAM_CALL_0:
				printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_SUBPROGRAM_CALL_1:
				printf("%s(expressions)\n", node->symbol->name);
				break;

			case NODE_TYPE_IO_STATEMENT_0:
				printf("read (read_list)\n");
				break;
			case NODE_TYPE_IO_STATEMENT_1:
				printf("write (write_list)\n");
				break;
			case NODE_TYPE_READ_LIST:
				printf("read_list, read_item\n");
				break;
			case NODE_TYPE_WRITE_LIST:
				printf("write_list, write_item\n");
				break;
			case NODE_TYPE_WRITE_ITEM:
				printf("%s\n", node->symbol->name);
				break;
			default:
				if (node->symbol) {
					printf("%s\n", node->symbol->name);
				}
				else {
					printf("%s\n", node->name);
				}
				break;
		}
	}

	for (int i=0; i<6; i++) {
		if (node->nodes[i])
			preorder_tree_traversal(node->nodes[i], depth+1);	
	}
}

node* make_node(char* node_name, int node_type, symbol *symbol, node* n0,
				node* n1, node* n2, node* n3, node* n4, node* n5) {
	node* new_node = (node *) malloc(sizeof(node));
	if(!new_node) {
		printf("Out of memory\n");
		exit(1);
	}
	else {
		new_node->type = node_type;
		new_node->name = strdup(node_name);
		new_node->symbol = symbol;
		new_node->nodes[0] = n0;
		new_node->nodes[1] = n1;
		new_node->nodes[2] = n2;
		new_node->nodes[3] = n3;
		new_node->nodes[4] = n4;
		new_node->nodes[5] = n5;
		return(new_node);
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