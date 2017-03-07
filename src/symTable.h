#ifndef HEADER_H
#define HEADER_H

#include <iostream>
#include <string>
#include <unordered_map>
#include <map>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;

// symbol table entry data structure
typedef struct sTableEntry{
    string type;
    void *value;
    ull size;
    ll offset;
} sEntry;
typedef unordered_map<string,sEntry *> symTable;

extern map<symTable *, symTable*> tParent;
extern map<string ,int> switchItem;

extern symTable GST;
extern symTable *curr;
extern string oper;


void switchItemMap();
void fprintStruct(sEntry *a, FILE *file);
void stInitialize();
void addKeywords();
void makeSymTable(string name);
void updateSymTable();
sEntry* lookup(string a);
sEntry* makeEntry(string type,void *value, ull size, ll offset);
void insertSymbol(symTable& table,string key,string type,void *value,ull size,ll offset);
void printSymTables(symTable *a, string filename);
#endif
