#pragma once

#define TRUE 1
#define FALSE 0

#define NAME_MAX  32
#define MAX_YYTEXT_ITEMS 50


#define NODETYPE_EMPTY 999
#define NODETYPE_PROGRAM 101
#define NODETYPE_HEADER 102
#define NODETYPE_DECLARATIONS 103
#define NODETYPE_CONSTDEFS 104
#define NODETYPE_CONSTANT_DEFS 105
#define NODETYPE_EXPRESSION 106
#define NODETYPE_CONSTANT 107
#define NODETYPE_TYPEDEFS 108
#define NODETYPE_TYPE_DEFS 109
#define NODETYPE_TYPE_DEF 110
#define NODETYPE_DIMS 111
#define NODETYPE_LIMIT 112
#define NODETYPE_LIMITS 113
#define NODETYPE_TYPENAME 114
#define NODETYPE_STANDARD_TYPE 115
#define NODETYPE_FIELDS 116
#define NODETYPE_FIELD 117
#define NODETYPE_IDENTIFIERS 118
#define NODETYPE_VARDEFS 119
#define NODETYPE_VARIABLE_DEFS 120
#define NODETYPE_SUBPROGRAMS 121
#define NODETYPE_SUBPROGRAM 122
#define NODETYPE_SUB_HEADER 123
#define NODETYPE_FORMAL_PARAMETERS 124
#define NODETYPE_PARAMETER_LIST 125
#define NODETYPE_PASS 126
#define NODETYPE_COMP_STATEMENT 127
#define NODETYPE_STATEMENTS 128
#define NODETYPE_VARIABLE 129
#define NODETYPE_STATEMENT 130
#define NODETYPE_IF_STATEMENT 131
#define NODETYPE_ASSIGNMENT 132
#define NODETYPE_EXPRESSIONS 133
#define NODETYPE_SUBPROGRAM_CALL 134
#define NODETYPE_SETEXPRESSION 135
#define NODETYPE_ELEXPRESSIONS 136
#define NODETYPE_ELEXPRESSION 137
#define NODETYPE_IO_STATEMENT 138
#define NODETYPE_READ_LIST 139
#define NODETYPE_READ_ITEM 140
#define NODETYPE_WHILE_STATEMENT 141
#define NODETYPE_FOR_STATEMENT 142
#define NODETYPE_ITER_SPACE 143
#define NODETYPE_WITH_STATEMENT 144
#define NODETYPE_WRITE_LIST 145
#define NODETYPE_WRITE_ITEM 146

#define NODETYPE_LPAREN 147
#define NODETYPE_RPAREN 148
#define NODETYPE_SEMI 149
#define NODETYPE_DOT 150
#define NODETYPE_COMMA 151
#define NODETYPE_EQU 152
#define NODETYPE_COLON 153
#define NODETYPE_LBRACK 154
#define NODETYPE_RBRACK 155
#define NODETYPE_ASSIGN 156
#define NODETYPE_DOTDOT 157

#define NODETYPE_KEYWORD_PROGRAM 158
#define NODETYPE_KEYWORD_CONST 159
#define NODETYPE_KEYWORD_TYPE 160
#define NODETYPE_KEYWORD_ARRAY 161
#define NODETYPE_KEYWORD_SET 162
#define NODETYPE_KEYWORD_OF 163
#define NODETYPE_KEYWORD_RECORD 164
#define NODETYPE_KEYWORD_VAR 165
#define NODETYPE_KEYWORD_FORWARD 166
#define NODETYPE_KEYWORD_FUNCTION 167
#define NODETYPE_KEYWORD_PROCEDURE 168
#define NODETYPE_KEYWORD_INTEGER 169
#define NODETYPE_KEYWORD_REAL 170
#define NODETYPE_KEYWORD_BOOLEAN 171
#define NODETYPE_KEYWORD_CHAR 172
#define NODETYPE_KEYWORD_BEGIN 173
#define NODETYPE_KEYWORD_END 174
#define NODETYPE_KEYWORD_IF 175
#define NODETYPE_KEYWORD_THEN 176
#define NODETYPE_KEYWORD_ELSE 177
#define NODETYPE_KEYWORD_WHILE 178
#define NODETYPE_KEYWORD_DO 179
#define NODETYPE_KEYWORD_FOR 180
#define NODETYPE_KEYWORD_DOWNTO 181
#define NODETYPE_KEYWORD_TO 182
#define NODETYPE_KEYWORD_WITH 183
#define NODETYPE_KEYWORD_READ 184
#define NODETYPE_KEYWORD_WRITE 185
#define NODETYPE_KEYWORD_OR 186
#define NODETYPE_KEYWORD_NOT 187
#define NODETYPE_KEYWORD_IN 188

#define NODETYPE_EXPRESSION_ADDOP_ADD 189
#define NODETYPE_EXPRESSION_ADDOP_SUB 190
#define NODETYPE_EXPRESSION_RELOP_NE 191
#define NODETYPE_EXPRESSION_RELOP_GE 192
#define NODETYPE_EXPRESSION_RELOP_LE 193
#define NODETYPE_EXPRESSION_RELOP_GT 194
#define NODETYPE_EXPRESSION_RELOP_LT 195
#define NODETYPE_EXPRESSION_MULDIVANDOP_MUL 196
#define NODETYPE_EXPRESSION_MULDIVANDOP_DIV 197
#define NODETYPE_EXPRESSION_MULDIVANDOP_DIV_E 198
#define NODETYPE_EXPRESSION_MULDIVANDOP_MOD 199
#define NODETYPE_EXPRESSION_MULDIVANDOP_AND 200

#define NODETYPE_ID 201
#define NODETYPE_ICONST 202
#define NODETYPE_RCONST_REAL 203
#define NODETYPE_RCONST_INT 204
#define NODETYPE_RCONST_HEX 205
#define NODETYPE_RCONST_BIN 206
#define NODETYPE_BCONST 207
#define NODETYPE_CCONST 208
#define NODETYPE_STRING 209

#define NODETYPE_EXPRESSION_ADDOP_ADD_UNARY 210
#define NODETYPE_EXPRESSION_ADDOP_SUB_UNARY 211
#define NODETYPE_EXPRESSION_EQU 212
#define NODETYPE_EXPRESSION_INOP 213
#define NODETYPE_EXPRESSION_OROP 214
#define NODETYPE_EXPRESSION_NOTOP 215
#define NODETYPE_EXPRESSION_ID_PAREN 216
#define NODETYPE_EXPRESSION_PAREN 217

#define NODETYPE_LIMIT_ADDOP_ADD_ICONST 218
#define NODETYPE_LIMIT_ADDOP_SUB_ICONST 219
#define NODETYPE_LIMIT_ADDOP_ADD_ID 220
#define NODETYPE_LIMIT_ADDOP_SUB_ID 221
#define NODETYPE_LIMIT_ICONST 222
#define NODETYPE_LIMIT_CCONST 223
#define NODETYPE_LIMIT_BCONST 224
#define NODETYPE_LIMIT_ID 225


typedef struct yytext_stack_struct {
	char* stack[MAX_YYTEXT_ITEMS];
	int size;
} yytext_stack_struct;

typedef struct dcl_tag {
   int dcl_type;                    /* -- ARRAY -------------- */
   int dim;                         /* -- Array dimension ---- */
   struct dcl_tag *next_dcl_type;
} dcl;

typedef struct symbol_tag {
   unsigned char name[NAME_MAX+1];  /* -- Variable name .----- */
   int sclass;                      /* -- REGISTER, CONSTANT,- */
                                    /* -- MEMORY, STACK. ----- */
   int typos;                       /* -- INT .--------------- */
   int timi;                        /* -- Value assigned . --- */
   int has_timi;                    /* -- FALSE if no value .- */
   int comes_from;                  /* -- IDENTIFIER, INTCONST,*/
                                    /* -- ARRAYELEM, ARITHEXPR,*/
                                    /* -- LOGICEXPR .--------- */
   int disposable;                  /* -- TRUE or FALSE .----- */
   int lvalue;                      /* -- TRUE or FALSE .----- */
   dcl *dcl_ptr;
   int dims;                        /* -- Temp for array dim . */
   struct symbol_tag *Next_in_Cross_Link;
   struct symbol_tag *NextSymbol;
   struct symbol_tag *PrevSymbol;
} symbol;

typedef struct node_tag{
	int depth;
	int type;
	char* name;
	struct symbol_tag* symbol;
	struct node_tag* nodes[6];
} node;

typedef struct parse_and_syntax_tree_tag {
   node* parse_tree;
   node* ast_tree;
} parse_and_syntax_tree;

void debug_yytext();
// void remove_last_yytext_element();
void preorder_tree_traversal(node *node, int depth);
void print_tabs(int depth);

yytext_stack_struct* yytext_stack;

symbol *Symbol_free; /* -- Symbol-list of recycled symbols -- */
node* make_node(char* node_name, int node_type, symbol *symbol, node* node_0, node* node_1, node* node_2, node* node_3, node* node_4, node* node_5);
node* make_node_id(char* node_name, int node_type, symbol *symbol);
symbol *new_symbol(char *name);
char* pop_yytext_stack();
void push_yytext_stack(char* yytext);
void create_node_types();

node* node_program;
node* node_const;
node* node_type;
node* node_array;
node* node_set;
node* node_of;
node* node_record;
node* node_var;
node* node_forward;
node* node_function;
node* node_procedure;
node* node_integer;
node* node_real;
node* node_boolean;
node* node_char;
node* node_begin;
node* node_end;
node* node_if;
node* node_then;
node* node_else;
node* node_while;
node* node_do;
node* node_for;
node* node_downto;
node* node_to;
node* node_with;
node* node_read;
node* node_write;
node* node_or;
node* node_not;
node* node_in;

node* node_lparen;
node* node_rparen;
node* node_semi;
node* node_dot;
node* node_comma;
node* node_equ;
node* node_colon;
node* node_lbrack;
node* node_rbrack;
node* node_assign;
node* node_dotdot;

node* node_addop_add;
node* node_addop_sub;
node* node_relop_ne;
node* node_relop_ge;
node* node_relop_le;
node* node_relop_gt;
node* node_relop_lt;
node* node_muldivandop_mul;
node* node_muldivandop_div;
node* node_muldivandop_div_e;
node* node_muldivandop_mod;
node* node_muldivandop_and;