#pragma once

#define TRUE 1
#define FALSE 0

#define NAME_MAX  32
#define MAX_STACK_ITEMS 100

#define NODE_TYPE_PROGRAM 500
#define NODE_TYPE_HEADER 501
#define NODE_TYPE_DECLARATIONS 502
#define NODE_TYPE_CONSTDEFS 503
#define NODE_TYPE_CONSTANT_DEFS_0 504
#define NODE_TYPE_CONSTANT_DEFS_1 505
#define NODE_TYPE_EXPRESSION_0 506
#define NODE_TYPE_EXPRESSION_1 507
#define NODE_TYPE_EXPRESSION_2 508
#define NODE_TYPE_EXPRESSION_3 509
#define NODE_TYPE_EXPRESSION_4 510
#define NODE_TYPE_EXPRESSION_5 511
#define NODE_TYPE_EXPRESSION_6 512
#define NODE_TYPE_EXPRESSION_7 513
#define NODE_TYPE_EXPRESSION_8 514
#define NODE_TYPE_EXPRESSION_9 515
#define NODE_TYPE_EXPRESSION_10 516
#define NODE_TYPE_EXPRESSION_11 517
#define NODE_TYPE_EXPRESSION_12 518
#define NODE_TYPE_EXPRESSION_13 519
#define NODE_TYPE_EXPRESSION_14 520
#define NODE_TYPE_EXPRESSION_15 521
#define NODE_TYPE_EXPRESSION_16 522
#define NODE_TYPE_EXPRESSION_17 523
#define NODE_TYPE_EXPRESSION_18 524
#define NODE_TYPE_EXPRESSION_19 525
#define NODE_TYPE_VARIABLE_0 526
#define NODE_TYPE_VARIABLE_1 527
#define NODE_TYPE_VARIABLE_2 528
#define NODE_TYPE_EXPRESSIONS 529
#define NODE_TYPE_CONSTANT_0 530
#define NODE_TYPE_CONSTANT_1 531
#define NODE_TYPE_CONSTANT_5 535
#define NODE_TYPE_CONSTANT_6 536
#define NODE_TYPE_SETEXPRESSION_0 537
#define NODE_TYPE_SETEXPRESSION_1 538
#define NODE_TYPE_ELEXPRESSIONS 539
#define NODE_TYPE_ELEXPRESSION 540
#define NODE_TYPE_TYPEDEFS 541
#define NODE_TYPE_TYPE_DEFS_0 542
#define NODE_TYPE_TYPE_DEFS_1 543
#define NODE_TYPE_TYPE_DEF_0 544
#define NODE_TYPE_TYPE_DEF_1 545
#define NODE_TYPE_TYPE_DEF_2 546
#define NODE_TYPE_TYPE_DEF_3 547
#define NODE_TYPE_TYPE_DEF_4 548
#define NODE_TYPE_DIMS 549
#define NODE_TYPE_LIMITS_0 550
#define NODE_TYPE_LIMITS_1 551
#define NODE_TYPE_LIMIT_0 552
#define NODE_TYPE_LIMIT_1 553
#define NODE_TYPE_LIMIT_2 554
#define NODE_TYPE_LIMIT_3 555
#define NODE_TYPE_LIMIT_4 556
#define NODE_TYPE_LIMIT_5 557
#define NODE_TYPE_LIMIT_6 558
#define NODE_TYPE_LIMIT_7 559
#define NODE_TYPE_TYPENAME 560
#define NODE_TYPE_FIELDS_0 561
#define NODE_TYPE_FIELDS_1 562
#define NODE_TYPE_FIELD 563
#define NODE_TYPE_IDENTIFIERS_0 564
#define NODE_TYPE_IDENTIFIERS_1 565
#define NODE_TYPE_VARDEFS 566
#define NODE_TYPE_VARIABLE_DEFS_0 567
#define NODE_TYPE_VARIABLE_DEFS_1 568
#define NODE_TYPE_SUBPROGRAMS 569
#define NODE_TYPE_SUBPROGRAM_0 570
#define NODE_TYPE_SUBPROGRAM_1 571
#define NODE_TYPE_SUB_HEADER_0 572
#define NODE_TYPE_SUB_HEADER_1 573
#define NODE_TYPE_SUB_HEADER_2 574
#define NODE_TYPE_FORMAL_PARAMETERS 575
#define NODE_TYPE_PARAMETER_LIST_0 576
#define NODE_TYPE_PARAMETER_LIST_1 577
#define NODE_TYPE_COMP_STATEMENT 578
#define NODE_TYPE_STATEMENTS 579
#define NODE_TYPE_ASSIGNMENT_0 580
#define NODE_TYPE_ASSIGNMENT_1 581
#define NODE_TYPE_IF_STATEMENT_0 582
#define NODE_TYPE_IF_STATEMENT_1 583
#define NODE_TYPE_WHILE_STATEMENT 584
#define NODE_TYPE_FOR_STATEMENT 585
#define NODE_TYPE_ITER_SPACE_0 586
#define NODE_TYPE_ITER_SPACE_1 587
#define NODE_TYPE_WITH_STATEMENT 588
#define NODE_TYPE_SUBPROGRAM_CALL_0 589
#define NODE_TYPE_SUBPROGRAM_CALL_1 590
#define NODE_TYPE_IO_STATEMENT_0 591
#define NODE_TYPE_IO_STATEMENT_1 592
#define NODE_TYPE_READ_LIST 593
#define NODE_TYPE_WRITE_LIST 594
#define NODE_TYPE_WRITE_ITEM 595
#define NODE_TYPE_INTEGER 596
#define NODE_TYPE_REAL 597
#define NODE_TYPE_BOOLEAN 598
#define NODE_TYPE_CHAR 599
#define NODE_TYPE_VAR 600

#define SYMBOL_TYPE_ICONST 601
#define SYMBOL_TYPE_RCONST 602
#define SYMBOL_TYPE_BCONST 603
#define SYMBOL_TYPE_CCONST 604

#define STACK_TYPE_ICONST 605
#define STACK_TYPE_RCONST 606
#define STACK_TYPE_BCONST 607
#define STACK_TYPE_CCONST 608
#define STACK_TYPE_STRING 609



typedef struct dcl_tag {
   int dcl_type;                    /* -- ARRAY -------------- */
   int dim;                         /* -- Array dimension ---- */
   struct dcl_tag *next_dcl_type;
} dcl;

union data {
   int iconst;
   double rconst;
   int bconst;
   char cconst;
   char* str;
} data; 

typedef struct stack_struct {
   // char* stack[MAX_STACK_ITEMS];
	union data stack[MAX_STACK_ITEMS];
   int type;
	int size;
} stack_struct;

typedef struct symbol_tag {
   // unsigned char name[NAME_MAX+1];  /* -- Variable name .----- */
   char* name;
   int sclass;                      /* -- REGISTER, CONSTANT,- */
                                    /* -- MEMORY, STACK. ----- */
   int typos;                       /* -- INT .--------------- */
   int timi;                        /* -- Value assigned . --- */
   union data value;
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
void preorder_tree_traversal(node *node, int depth);
void print_tabs(int depth);

stack_struct* yytext_stack;

symbol *Symbol_free; /* -- Symbol-list of recycled symbols -- */
node* make_node(char* node_name, int node_type, symbol *symbol, node* node_0, node* node_1, node* node_2, node* node_3, node* node_4, node* node_5);
node* make_node_id(char* node_name, int node_type, symbol *symbol);
symbol *new_symbol(char *name);
void parse_value(symbol* out_symbol, symbol* in_symbol, int type);
char* pop(stack_struct* stack);
void push_string(stack_struct* stack, char* yytext);
void push_iconst(stack_struct* stack, int value);
void print(stack_struct* stack);
int evaluate_expression(symbol* smbl, symbol* s1, symbol* s2, int operation);
void generate_code(node* node);
void remove_at_index(stack_struct* stack, int index);