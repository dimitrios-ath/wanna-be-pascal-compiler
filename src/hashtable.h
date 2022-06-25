#pragma once
#include <stdlib.h>

struct _slot {
	char *key;
	// union _data *data;
	int data;
	int type;
	int scope;
	struct _slot *next;
};

union _data {
	int integer;
	double real;
	int boolean;
	char chr;
	char* string;
};

typedef struct hashtable {
	int size;
	struct _slot **slots;
} hashtable;


hashtable* create_hashtable(int size);
void hashtbl_destroy(hashtable *hashtbl);
// int hashtbl_insert(hashtable* hash_table, const char *key, union _data data, int type, int scope);
int hashtable_insert(hashtable* hash_table, const char *key, int data, int type, int scope);
int hashtbl_remove(hashtable *hashtbl, const char *key,int scope);
void *hashtable_get(hashtable *hashtbl, int scope);