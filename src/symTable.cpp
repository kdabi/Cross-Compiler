#include "symTable.h"

map<symTable *, symTable*> tParent;
map<string ,int> switchItem;

symTable GST;
symTable *curr;

void switchItemMap(){
   switchItem.insert(make_pair<string, int>("string", 1));
   switchItem.insert(make_pair<string, int>("int", 2));
   switchItem.insert(make_pair<string, int>("func", 3));
}

void stInitialize(){
    switchItemMap();
    tParent.insert(make_pair<symTable*, symTable*>(&GST, NULL));
    curr = &GST;
}

sEntry* makeEntry(string type,void *value,ull size,ll offset){
    sEntry* mynew = new sEntry();
    mynew->type = type;
    mynew->size = size;
    mynew->offset = offset;
    mynew->value = value;
    return mynew;
}

void insertSymbol(symTable& table,string key,string type,void *value,ull size,ll offset){
   table.insert (pair<string,sEntry *>(key,makeEntry(type,value,size,offset)));
   return;
}

void printStruct(sEntry *a){
    cout << a->type << " ";

    switch(switchItem[a->type]){
        case 1:{ string* tmp = (string  *)(a->value);
                 cout << *tmp << endl;
                 break;
               }
        case 2:{ int* tmp = (int  *)(a->value);
                 cout << *tmp << endl;
                 break;
                }
    } //cout << (int)switchitem[a->type] << endl;

}

void makeSymTable(string name){
    symTable* myTable = new symTable;
    insertSymbol(*curr,name,"func",&myTable,0,0);
    tParent.insert(pair<symTable*, symTable*>(myTable,curr));
    curr = myTable;
}

void updateSymTable(){
    curr = tParent[curr];
}

sEntry* lookup(string a){
   symTable * tmp;
   tmp = curr;
   while (tmp!=NULL){
      if ((*tmp)[a]){
         return (*tmp)[a];
         //break;
      }
      if(tParent[tmp]!=NULL) tmp= tParent[tmp];
      else break;
   }
   return NULL;
}

