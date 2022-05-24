#pragma once

#define MAX_YYTEXT_ITEMS 50

typedef struct yytexts_ {
	char* yytext[MAX_YYTEXT_ITEMS];
	int slots;
} yytexts_;

typedef struct node{
	char* value;
	int depth;
	struct node *node1;
	struct node *node2;
	struct node *node3;
	struct node *node4;
	struct node *node5;
	struct node *node6;
} node;

yytexts_ *yytexts;
void debug_yytext();
void remove_last_yytext_element();
void update_tree_depths(struct node *node, int depth);
void preorder_tree_traversal(struct node *node);