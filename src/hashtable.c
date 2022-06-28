#include"hashtable.h"

#include<string.h>
#include<stdio.h>

extern FILE *yyin;
extern FILE *yyout;

hashtable* hash_table;

// http://www.cse.yorku.ca/~oz/hash.html
unsigned int hash_function(const char* str) {
        unsigned int hash = 5381;
        int c;
        while ((c = *str++))
            hash = ((hash << 5) + hash) + c; 
        return hash % hash_table->size;
    }

void initialize_hashtable(int size) {
    hash_table = malloc(sizeof(hashtable));
    hash_table->slots=calloc(size, sizeof(struct slot*));
	hash_table->size = size;
}

int add_symbol(symbol* smbl) {
	int hash = hash_function(smbl->name);
	slot* slot = hash_table->slots[hash];
	while(slot) {
		if(!strcmp(slot->symbol->name, smbl->name)) {
			// printf("symbol \"%s\" already declared", smbl->name);
			slot->symbol = smbl;
			return 1;
		}	
		slot = slot->next;
	}
    slot = calloc(1, sizeof(slot));
	if (!slot)
        return 0;
    slot->symbol = smbl;
	slot->next = hash_table->slots[hash];
	hash_table->slots[hash] = slot;
	return 1;
}

symbol* find_symbol(symbol* smbl) {
	int hash = hash_function(smbl->name);
	slot* slot = hash_table->slots[hash];
	while(slot) {
		if(!strcmp(slot->symbol->name, smbl->name)) {
			return slot->symbol;
		}	
		slot = slot->next;
	}
	return NULL;
}

void hashtable_get()
{
	slot *slot;
	printf("+------------------------------------------------+\n");
	printf("|                  Symbol Table                  |\n");
	printf("+------------------------------------------------+\n");
	printf("| %-15s | %-15s | %-10s |\n", "Name", "Value", "Type");
	printf("+------------------------------------------------+\n");
	for (int n=0; n < hash_table->size; n++) {
		slot = hash_table->slots[n];
		while(slot) {
			if (slot->symbol) {
				switch (slot->symbol->typos) {
				case SYMBOL_TYPE_ICONST:
					printf("| %-15s | %-15d | %-10s |\n", slot->symbol->name, slot->symbol->value.iconst, "ICONST"); 
					break;
				case SYMBOL_TYPE_RCONST:
					printf("| %-15s | %-15.5f | %-10s |\n", slot->symbol->name, slot->symbol->value.rconst, "RCONST"); 
					break;
				case SYMBOL_TYPE_BCONST:
					printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, slot->symbol->value.bconst?"TRUE":"FALSE", "BCONST"); 
					break;
				case SYMBOL_TYPE_CCONST:
					switch (slot->symbol->value.cconst) {
						case '\n':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\n", "CCONST");
							break;
						case '\f':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\f", "CCONST");
							break;
						case '\t':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\t", "CCONST");
							break;
						case '\r':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\r", "CCONST");
							break;
						case '\b':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\b", "CCONST");
							break;
						case '\v':
							printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "\\v", "CCONST");
							break;
						default:
							printf("| %-15s | %-15c | %-10s |\n", slot->symbol->name, slot->symbol->value.cconst, "CCONST");
					}
					break;
				default:
					printf("| %-15s | %-15s | %-10s |\n", slot->symbol->name, "UNKNOWN", "UNKNOWN"); 
				}
			}
			slot = slot->next;
		}
	}
	printf("+------------------------------------------------+\n");
}