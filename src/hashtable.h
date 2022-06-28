#pragma once
#include <stdlib.h>
#include "defs.h"

typedef struct slot {
	symbol* symbol;
	struct slot *next;
} slot;

typedef struct hashtable {
	int size;
	slot **slots;
} hashtable;


void initialize_hashtable(int size);
void hashtable_get();
int add_symbol(symbol*);
symbol* find_symbol(symbol*);