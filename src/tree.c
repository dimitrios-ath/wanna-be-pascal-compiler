#include <stdio.h>
#include "tree.h"

void remove_last_yytext_element() {
	yytexts->yytext[yytexts->slots-1]=NULL;
	yytexts->slots--;
}

void debug_yytext() {
	printf("Number of used slots = %d\n\n", yytexts->slots);
	for (int i=0; i<yytexts->slots; i++)
		printf("%s\n", yytexts->yytext[i]);
	printf("\n");
}

void preorder_tree_traversal(struct node *node) {
	if (!node)
		return;
	else {
		for (int i=0; i<node->depth; i++)
			// printf("    ");
			// printf("◦   ");
			printf("‣   ");
		printf("%s\n", node->value);
	}

	if (node->node1)
		preorder_tree_traversal(node->node1);
	if (node->node2)
		preorder_tree_traversal(node->node2);
	if (node->node3)
		preorder_tree_traversal(node->node3);
	if (node->node4)
		preorder_tree_traversal(node->node4);
	if (node->node5)
		preorder_tree_traversal(node->node5);
	if (node->node6)
		preorder_tree_traversal(node->node6);
}

void update_tree_depths(struct node *node, int depth) {
	node->depth = depth;

	if (node->node1)
		update_tree_depths(node->node1, depth+1);
	if (node->node2)
		update_tree_depths(node->node2, depth+1);
	if (node->node3)
		update_tree_depths(node->node3, depth+1);
	if (node->node4)
		update_tree_depths(node->node4, depth+1);
	if (node->node5)
		update_tree_depths(node->node5, depth+1);
	if (node->node6)
		update_tree_depths(node->node6, depth+1);
}