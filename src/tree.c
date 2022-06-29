#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashtable.h"
#include <math.h>
#include "defs.h"

#define FREE 0
#define USED 1
int registers_state[8][2] = {{0,FREE}, {1,FREE}, {2,FREE}, {3,FREE}, 
							 {4,FREE}, {5,FREE}, {6,FREE}, {7,FREE}};

stack_struct* registers_stack;

void free_register(int i) {
	registers_state[i][1]=FREE;
}

void set_register_state(int r, int state) {
	registers_state[r][1] = state;
}

void print_registers() {
	printf("REGISTERS:\n");
	for (int i=0; i<8; i++)
		printf("$t%d: %s\n",i , registers_state[i][1]?"USED":"FREE");
	printf("\n");
}

int pop_register_stack() {
	int ret = registers_stack->stack[registers_stack->size-1].iconst;
	set_register_state(registers_stack->stack[registers_stack->size-1].iconst, FREE);
	registers_stack->stack[--registers_stack->size].iconst = 0;
	return ret;
}

char* pop(stack_struct* stack) {
	char* ret = stack->stack[stack->size-1].str;
	stack->stack[--stack->size].str = NULL;
	return ret;
}

int next_free_register() {
	// print_registers();
	for (int i=0; i<8; i++)
		if (registers_state[i][1]==FREE) {
			registers_state[i][1]=USED;
			return i;
		}
	return -1;
}

void push_string(stack_struct* stack, char* yytext) {
	stack->stack[stack->size++].str = strdup(yytext);
}

void push_iconst(stack_struct* stack, int value) {
	stack->stack[stack->size++].iconst = value;
}

void print(stack_struct* stack) {
	printf("\n-----\nStack\n-----\n");
	switch (stack->type) {
	case STACK_TYPE_STRING:
		for (int i=0; i<stack->size; i++) {
			printf("%d: %s\n", i, stack->stack[i].str);
		}
		break;

	case STACK_TYPE_ICONST:
		for (int i=0; i<stack->size; i++) {
			printf("%d: %d\n", i, stack->stack[i].iconst);
		}
		break;
	
	default:
		break;
	}
	
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

symbol *new_symbol(char *name) {  
	symbol *smbl;
	smbl=(symbol *)calloc(1, sizeof(symbol));
	smbl->name = strdup(name);
	smbl->timi=0;
	smbl->disposable=FALSE;
	smbl->lvalue=TRUE;
	smbl->Next_in_Cross_Link=NULL;
	smbl->NextSymbol=NULL;
	smbl->PrevSymbol=NULL;
	return(smbl);
}

// https://stackoverflow.com/questions/40337939/floating-point-equivalent-to-strtol-in-c
float new_strtof(char* const ostr, char** endptr, unsigned char base)
{
    char* str = (char*)malloc(strlen(ostr) + 1);
    strcpy(str, ostr);
    const char* dot = ".";

    /* I do not validate any input here, nor do I do anything with endptr */      //Let's assume input of 101.1101, null, 2 (binary)
    char *cbefore_the_dot = strtok(str, dot); //Will be 101
    char *cafter_the_dot = strtok(NULL, dot); //Will be 0101

    float f = (float)strtol (cbefore_the_dot, 0, base); //Base would be 2 = binary. This would be 101 in decimal which is 5
    int i, sign = (str[0] == '-'? -1 : 1);
    char n[2] = { 0 }; //will be just for a digit at a time

    for(i = 0 ; cafter_the_dot[i] ; i++) //iterating the fraction string
    {
        n[0] = cafter_the_dot[i];
        f += strtol(n, 0, base) * pow(base, -(i + 1)) * sign; //converting the fraction part
    }

    free(str);
    return f;
}

int evaluate_expression(symbol* smbl, symbol* s1, symbol* s2, int operation) {
	switch (operation) {

		case NODE_TYPE_EXPRESSION_8: // expression ADDOP_ADD expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = s1->value.iconst + s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.iconst + s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.rconst = s1->value.rconst + s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.rconst + s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_EXPRESSION_9: // expression ADDOP_SUB expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = s1->value.iconst - s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.iconst - s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.rconst = s1->value.rconst - s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.rconst - s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_EXPRESSION_10: // expression MULDIVANDOP_MUL expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = s1->value.iconst * s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.iconst * s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.rconst = s1->value.rconst * s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.rconst * s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_EXPRESSION_11: // expression MULDIVANDOP_DIV expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.rconst = s1->value.iconst / (double) s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.iconst / s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.rconst = s1->value.rconst / s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST && s2->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = s1->value.rconst / s2->value.rconst;
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else return 0;
			return 1;
			break;
		
		case NODE_TYPE_EXPRESSION_12: // expression MULDIVANDOP_DIV_E expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = s1->value.iconst / s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_EXPRESSION_13: // expression MULDIVANDOP_MOD expression
			if (s1->typos == SYMBOL_TYPE_ICONST && s2->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = s1->value.iconst % s2->value.iconst;
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else return 0;
			return 1;
			break;
		case NODE_TYPE_EXPRESSION_15: // ADDOP_ADD expression
			if (s1->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = +(s1->value.iconst);
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = +(s1->value.rconst);
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_EXPRESSION_16: // ADDOP_SUB expression
			if (s1) {
				if (s1->typos == SYMBOL_TYPE_ICONST) {
					smbl->value.iconst = -(s1->value.iconst);
					smbl->typos = SYMBOL_TYPE_ICONST;
				}
				else if (s1->typos == SYMBOL_TYPE_RCONST) {
					smbl->value.rconst = -(s1->value.rconst);
					smbl->typos = SYMBOL_TYPE_RCONST;
				}
				else return 0;
				return 1;
			}
			return 0;
			break;

		case NODE_TYPE_EXPRESSION_19: // LPAREN expression RPAREN
			if (s1->typos == SYMBOL_TYPE_ICONST) {
				smbl->value.iconst = (s1->value.iconst);
				smbl->typos = SYMBOL_TYPE_ICONST;
			}
			else if (s1->typos == SYMBOL_TYPE_RCONST) {
				smbl->value.rconst = (s1->value.rconst);
				smbl->typos = SYMBOL_TYPE_RCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_BCONST) {
				smbl->value.bconst = (s1->value.bconst);
				smbl->typos = SYMBOL_TYPE_BCONST;
			}
			else if (s1->typos == SYMBOL_TYPE_CCONST) {
				smbl->value.cconst = (s1->value.cconst);
				smbl->typos = SYMBOL_TYPE_CCONST;
			}
			else return 0;
			return 1;
			break;

		case NODE_TYPE_ASSIGNMENT_0: // variable ASSIGN expression
			if (s1->typos == s2->typos) {
				smbl->value.iconst = s2->value.iconst; // TODO need to check other data types
				smbl->typos = s2->typos;
			}
			else return 0;
			return 1;
			break;

		default:
			break;
	}
	return 0;
}

void parse_value(symbol* out_symbol, symbol* in_symbol, int type) {
	switch (type) {
		case NODE_TYPE_CONSTANT_0: // ICONST
			if (strlen(in_symbol->name) > 2) {
				if (in_symbol->name[0] == '0' && (in_symbol->name[1] == 'H' || in_symbol->name[1] == 'h')) // ICONST in hex form
					out_symbol->value.iconst = strtol(in_symbol->name+2, NULL, 16);
				else if (in_symbol->name[0] == '0' && (in_symbol->name[1] == 'B' || in_symbol->name[1] == 'b')) // ICONST in binary form
					out_symbol->value.iconst = strtol(in_symbol->name+2, NULL, 2);
				else // ICONST in decimal form
					out_symbol->value.iconst = atoi(in_symbol->name);
			}
			else // ICONST in decimal form
				out_symbol->value.iconst = atoi(in_symbol->name);
			out_symbol->typos = SYMBOL_TYPE_ICONST;
			break;
		case NODE_TYPE_CONSTANT_1: // RCONST
			if (strlen(in_symbol->name) > 2) {
				if (in_symbol->name[0] == '0' && (in_symbol->name[1] == 'H' || in_symbol->name[1] == 'h')) // RCONST in hex form
					out_symbol->value.rconst = new_strtof(in_symbol->name+2, NULL, 16);
				else if (in_symbol->name[0] == '0' && (in_symbol->name[1] == 'B' || in_symbol->name[1] == 'b')) // ICONST in binary form
					out_symbol->value.rconst = new_strtof(in_symbol->name+2, NULL, 2);
				else // RCONST in decimal form
					out_symbol->value.rconst = atof(in_symbol->name);
			}
			else // ICONST in decimal form
				out_symbol->value.rconst = atof(in_symbol->name);
			out_symbol->typos = SYMBOL_TYPE_RCONST;
			break;
		case NODE_TYPE_CONSTANT_5: // BCONST
			if (!strcmp(in_symbol->name, "FALSE") || !strcmp(in_symbol->name, "FALSE"))
				out_symbol->value.bconst = 0;
			else
				out_symbol->value.bconst = 1;
			out_symbol->typos = SYMBOL_TYPE_BCONST;
			break;
		case NODE_TYPE_CONSTANT_6: // CCONST
			if (in_symbol->name[1] == '\\') {
				switch (in_symbol->name[2]) {
				case 'n':
					out_symbol->value.cconst = '\n';
					break;
				case 'f':
					out_symbol->value.cconst = '\f';
					break;
				case 't':
					out_symbol->value.cconst = '\t';
					break;
				case 'r':
					out_symbol->value.cconst = '\r';
					break;
				case 'b':
					out_symbol->value.cconst = '\b';
					break;
				case 'v':
					out_symbol->value.cconst = '\v';
					break;
				}
			}
			else
				out_symbol->value.cconst = in_symbol->name[1];
			out_symbol->typos = SYMBOL_TYPE_CCONST;
			break;
		case NODE_TYPE_EXPRESSION_8: // expression ADDOP_ADD expression
		case NODE_TYPE_EXPRESSION_9: // expression ADDOP_SUB expression
		case NODE_TYPE_EXPRESSION_10: // expression MULDIVANDOP_MUL expression
		case NODE_TYPE_EXPRESSION_11: // expression MULDIVANDOP_DIV expression
		case NODE_TYPE_EXPRESSION_12: // expression MULDIVANDOP_DIV_E expression
		case NODE_TYPE_EXPRESSION_13: // expression MULDIVANDOP_MOD expression
		case NODE_TYPE_EXPRESSION_15: // ADDOP_ADD expression
		case NODE_TYPE_EXPRESSION_16: // ADDOP_SUB expression
		case NODE_TYPE_EXPRESSION_19: // LPAREN expression RPAREN
			if (in_symbol->typos==SYMBOL_TYPE_ICONST) {
				out_symbol->value.iconst = in_symbol->value.iconst;
				out_symbol->typos = SYMBOL_TYPE_ICONST;
			}
			else if (in_symbol->typos==SYMBOL_TYPE_RCONST) {
				out_symbol->value.rconst = in_symbol->value.rconst;
				out_symbol->typos = SYMBOL_TYPE_RCONST;
			}
			else if (in_symbol->typos==SYMBOL_TYPE_BCONST) {
				out_symbol->value.bconst = in_symbol->value.bconst;
				out_symbol->typos = SYMBOL_TYPE_BCONST;
			}
			else if (in_symbol->typos==SYMBOL_TYPE_CCONST) {
				out_symbol->value.cconst = in_symbol->value.cconst;
				out_symbol->typos = SYMBOL_TYPE_CCONST;
			}
			break;
	}
}

void generate_code(node* node) {
	if (node) {
		int r1, r2, operand1, operand2, result_register;
		switch (node->type) {
			case NODE_TYPE_PROGRAM:
				generate_code(node->nodes[0]); // NODE_TYPE_HEADER
				generate_code(node->nodes[1]); // NODE_TYPE_DECLARATIONS
				printf(".text\n");
				generate_code(node->nodes[2]); // subprograms
				printf("\n.main\n");
				generate_code(node->nodes[3]); // NODE_TYPE_COMP_STATEMENT
				break;
			case NODE_TYPE_HEADER:
				printf("# assembly of program \"%s\"\n", node->symbol->name);
				break;
			case NODE_TYPE_DECLARATIONS:
				printf("\n.data\n");
				generate_code(node->nodes[0]); // NODE_TYPE_CONSTDEFS
				generate_code(node->nodes[1]); // typedefs
				generate_code(node->nodes[2]); // vardefs
				break;
			case NODE_TYPE_CONSTDEFS:
				// printf("const constant_defs;\n");
				generate_code(node->nodes[0]);
				break;
			case NODE_TYPE_CONSTANT_DEFS_0:
				printf("\t%s:\t.word %d\n", node->symbol->name, find_symbol(node->symbol)->value.iconst);
				generate_code(node->nodes[0]);
				break;
			case NODE_TYPE_CONSTANT_DEFS_1:
				printf("\t%s:\t.word %d\n", node->symbol->name, find_symbol(node->symbol)->value.iconst);
				break;
			case NODE_TYPE_EXPRESSION_8:
				// printf("expression + expression\n");
				generate_code(node->nodes[0]); // expression
				generate_code(node->nodes[1]); // expression
				
				r1 = next_free_register();
				if (node->nodes[0]->type == NODE_TYPE_VARIABLE_0) {
					printf("\tlw\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 VARIABLE
					push_iconst(registers_stack, r1);
				}
				else if (node->nodes[0]->type == NODE_TYPE_CONSTANT_0) {
					printf("\tli\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 ICONST
					push_iconst(registers_stack, r1);
				}
				
				r2 = next_free_register();
				if (node->nodes[1]->type == NODE_TYPE_VARIABLE_0) { // OPERAND_2 VARIABLE
					printf("\tlw\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				else if (node->nodes[1]->type == NODE_TYPE_CONSTANT_0) { // OPERAND_2 ICONST
					printf("\tli\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				
				set_register_state(r1, FREE);
				set_register_state(r2, FREE);

				operand1 = pop_register_stack();
				operand2 = pop_register_stack();
				result_register = next_free_register();
				printf("\tadd\t$t%d, $t%d, $t%d\n", result_register, operand1, operand2);
				push_iconst(registers_stack, result_register);
				// set_register_state(result_register, FREE);
				break;

			case NODE_TYPE_EXPRESSION_9:
				// printf("expression - expression\n");
				generate_code(node->nodes[0]); // expression
				generate_code(node->nodes[1]); // expression
				
				r1 = next_free_register();
				if (node->nodes[0]->type == NODE_TYPE_VARIABLE_0) {
					printf("\tlw\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 VARIABLE
					push_iconst(registers_stack, r1);
				}
				else if (node->nodes[0]->type == NODE_TYPE_CONSTANT_0) {
					printf("\tli\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 ICONST
					push_iconst(registers_stack, r1);
				}
				
				r2 = next_free_register();
				if (node->nodes[1]->type == NODE_TYPE_VARIABLE_0) { // OPERAND_2 VARIABLE
					printf("\tlw\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				else if (node->nodes[1]->type == NODE_TYPE_CONSTANT_0) { // OPERAND_2 ICONST
					printf("\tli\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				
				set_register_state(r1, FREE);
				set_register_state(r2, FREE);

				operand1 = pop_register_stack();
				operand2 = pop_register_stack();
				result_register = next_free_register();
				printf("\tsub\t$t%d, $t%d, $t%d\n", result_register, operand2, operand1);
				push_iconst(registers_stack, result_register);
				// set_register_state(result_register, FREE);
				break;

			case NODE_TYPE_EXPRESSION_10:
				// printf("expression * expression\n");
				generate_code(node->nodes[0]); // expression
				generate_code(node->nodes[1]); // expression
				
				r1 = next_free_register();
				if (node->nodes[0]->type == NODE_TYPE_VARIABLE_0) {
					printf("\tlw\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 VARIABLE
					push_iconst(registers_stack, r1);
				}
				else if (node->nodes[0]->type == NODE_TYPE_CONSTANT_0) {
					printf("\tli\t$t%d, %s\n", r1, node->nodes[0]->symbol->name); // OPERAND_1 ICONST
					push_iconst(registers_stack, r1);
				}
				
				r2 = next_free_register();
				if (node->nodes[1]->type == NODE_TYPE_VARIABLE_0) { // OPERAND_2 VARIABLE
					printf("\tlw\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				else if (node->nodes[1]->type == NODE_TYPE_CONSTANT_0) { // OPERAND_2 ICONST
					printf("\tli\t$t%d, %s\n", r2, node->nodes[1]->symbol->name);
					push_iconst(registers_stack, r2);
				}
				
				set_register_state(r2, FREE);
				set_register_state(r1, FREE);

				operand1 = pop_register_stack();
				operand2 = pop_register_stack();
				result_register = next_free_register();
				printf("\tmul\t$t%d, $t%d, $t%d\n", result_register, operand1, operand2);
				push_iconst(registers_stack, result_register);
				// set_register_state(result_register, FREE);
				// pop_register_stack();
				// print(registers_stack);
				break;

			case NODE_TYPE_VARIABLE_0:
				break;
			case NODE_TYPE_CONSTANT_0:
			case NODE_TYPE_CONSTANT_1:
			case NODE_TYPE_CONSTANT_5:
			case NODE_TYPE_CONSTANT_6:
				// printf("%s\n", node->symbol->name);
				break;
			case NODE_TYPE_COMP_STATEMENT:
				generate_code(node->nodes[0]); 
				break;
			case NODE_TYPE_STATEMENTS:
				generate_code(node->nodes[0]); // statements
				generate_code(node->nodes[1]); // statement
				break;
			case NODE_TYPE_ASSIGNMENT_0:
				// printf("variable := expression\n");
				generate_code(node->nodes[1]); // expression
				int register_to_store = pop_register_stack();
				printf("\tsw\t$t%d, %s\n", register_to_store, node->nodes[0]->symbol->name);
				break;
			
			case NODE_TYPE_IO_STATEMENT_1:
				printf("\tadd\t$v0, $zero, 1\n");
				printf("\tlw\t$a0, %s\n", node->nodes[0]->symbol->name);
				printf("\tsyscall\n");
				break;
		}
	}
}