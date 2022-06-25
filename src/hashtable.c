#include"hashtable.h"

#include<string.h>
#include<stdio.h>

extern FILE *yyin;
extern FILE *yyout;

// http://www.cse.yorku.ca/~oz/hash.html
unsigned int hash_function(const char* str, int size) {
        unsigned int hash = 5381;
        int c;

        while (c = *str++)
            hash = ((hash << 5) + hash) + c; 

        return hash%size;
    }

hashtable* create_hashtable(int size) {
	hashtable* hash_table;

    hash_table = malloc(sizeof(hashtable));
	if (!hash_table) 
        return NULL;

    hash_table->slots=calloc(size, sizeof(struct slot*));
	if (!hash_table->slots) {
		free(hash_table);
		return NULL;
	}

	hash_table->size=size;

	return hash_table;
}

// void hashtbl_destroy(HASHTBL *hashtbl)
// {
// 	int n;
// 	struct hashnode_s *node, *oldnode;
	
// 	for(n=0; n<hashtbl->size; ++n) {
// 		node=hashtbl->nodes[n];
// 		while(node) {
// 			free(node->key);
// 			oldnode=node;
// 			node=node->next;
// 			free(oldnode);
// 		}
// 	}
// 	free(hashtbl->nodes);
// 	free(hashtbl);
// }

// int hashtbl_insert(hashtable* hash_table, const char *key, union _data data, int type, int scope)
// {
// 	struct _slot* slot;
// 	int hash=hash_function(key, hash_table->size);

// 	// printf("HASHTBL_INSERT(): KEY = %s, HASH = %ld,  \tDATA = %s, SCOPE = %d\n", key, hash, (char*)data, scope);

// 	slot = hash_table->slots[hash];
// 	while(slot) {
// 		if(!strcmp(slot->key, key) && (slot->scope == scope)) { // update existing variable
// 			// slot->data. = data; // cases here
// 			return 0;
// 		}
// 		slot = slot->next;
// 	}

//     slot = malloc(sizeof(struct _slot));
// 	if (!slot)
//         return -1;

//     slot->key=mystrdup(key);
// 	if(!slot->key) {
// 		free(slot);
// 		return -1;
// 	}

// 	slot->data=data;
// 	slot->scope = scope;
// 	slot->next=hashtbl->nodes[hash];
// 	hashtbl->nodes[hash]=slot;

// 	return 0;
// }

int hashtable_insert(hashtable* hash_table, const char *key, int data, int type, int scope)
{
	struct _slot* slot;
	int hash=hash_function(key, hash_table->size);

	// printf("HASHTBL_INSERT(): \tKEY = %s, \tHASH = %d,  \tDATA = %d, \tTYPE = %d, SCOPE = %d\n", key, hash, data, type, scope);

	slot = hash_table->slots[hash];
	while(slot) {
		if(!strcmp(slot->key, key) && (slot->scope == scope)) { // update existing variable
			slot->data = data;
			return 0;
		}
		slot = slot->next;
	}

    slot = malloc(sizeof(struct _slot));
	if (!slot)
        return -1;

    slot->key = strdup(key);
	if(!slot->key) {
		free(slot);
		return -1;
	}

	slot->data = data;
    slot->type = type;
	slot->scope = scope;
	slot->next = hash_table->slots[hash];
	hash_table->slots[hash] = slot;

	return 0;
}

// int hashtbl_remove(HASHTBL *hashtbl, const char *key,int scope)
// {
// 	struct hashnode_s *node, *prevnode=NULL;
// 	int hash=hashtbl->hashfunc(key)%hashtbl->size;

// 	node=hashtbl->nodes[hash];
// 	while(node) {
// 		if((!strcmp(node->key, key)) && (node->scope == scope)) {
// 			free(node->key);
// 			if(prevnode) prevnode->next=node->next;
// 			else hashtbl->nodes[hash]=node->next;
// 			free(node);
// 			return 0;
// 		}
// 		prevnode=node;
// 		node=node->next;
// 	}

// 	return -1;
// }

void *hashtable_get(hashtable *hash_table, int scope)
{
	struct _slot *slot;
		
	for (int n=0; n < hash_table->size; ++n) {
		slot=hash_table->slots[n];
		while(slot) {
			if(slot->scope == scope) {
                // printf("HASHTBL_get(): \tKEY = %s, \tDATA = %d, \tTYPE = %d, SCOPE = %d\n", slot->key, slot->data, slot->type, slot->scope);
				// printf("HASHTBL_GET():\tSCOPE = %d, KEY = %s,  \tDATA = %s\n", slot->scope, slot->key, (char*)slot->data);
				slot = slot->next;
			}
            else
				slot = slot->next;
		}
	}
	
	return NULL;
}