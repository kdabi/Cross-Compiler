#include <iostream>
#include <string>
#include <string.h>
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

extern map<string , string> funcArgumentMap;
extern map<symTable *, symTable*> tParent;
extern map<symTable *, int > symTable_types;
extern map<string ,int> switchItem;
extern map<int, string> statusMap;
extern long int blockSize[100];
extern int blockNo;
extern long long offsetG[100];
extern int offsetGNo;

extern symTable GST;
extern symTable *curr;
extern int is_next;

void paramTable();
ull getSize (char* id);
string returnSymType(string key);
void switchItemMap();
void fprintStruct(sEntry *a, FILE *file);
void stInitialize();
void addKeywords();
void update_isInit(string key);
void makeSymTable(string name,int type,string funcType);
void insertFuncArguments(string a,string b);
//void updateKey(string key,void *val);
void updateSymTable(string key);
sEntry* lookup(string a);
sEntry* scopeLookup(string a);
sEntry* makeEntry(string type, ull size, ll offset,int isInit);
void insertSymbol(symTable& table,string key,string type,ull size,ll offset,int isInit);
void printSymTables(symTable *a, string filename);
void printFuncArguments();
string funcArgList(string key);
void updateSymtableSize(string key);
void updateOffset(string key1,string key2);
bool insertStructSymbol(string key, string type, ull size, ull offset, int isInit );
bool endStructTable(string structName);
void makeStructTable();
int structLookup(string structName, string idStruct);
bool isStruct(string structName);
string structMemberType(string structName, string idT);
