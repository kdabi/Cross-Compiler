
#include <iostream>
#include <string>
#include <unordered_map>
#include <map>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;

enum symTable_types{
	S_FILE,S_BLOCK,S_FUNC,S_PROTO
};

// symbol table entry data structure
typedef struct sTableEntry{
    string type;
    int is_init;
 //   void *value;
    ull size;
    ll offset;
} sEntry;
typedef unordered_map<string,sEntry *> symTable;

extern map<symTable *, symTable*> tParent;
extern map<symTable *, int > symTable_types;
extern map<string ,int> switchItem;
extern map<int, string> statusMap;

extern symTable GST;
extern symTable *curr;
extern int is_next;

void paramTable();
string returnSymType(string key);
void switchItemMap();
void fprintStruct(sEntry *a, FILE *file);
void stInitialize();
void addKeywords();
void makeSymTable(string name,int type,string funcType);
//void updateKey(string key,void *val);
void updateSymTable();
sEntry* lookup(string a);
sEntry* makeEntry(string type, ull size, ll offset,int isInit);
void insertSymbol(symTable& table,string key,string type,ull size,ll offset,int isInit);
void printSymTables(symTable *a, string filename);
