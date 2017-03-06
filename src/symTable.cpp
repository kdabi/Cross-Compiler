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

void fprintStruct(sEntry *a, FILE* file){
    cout << a->type << " " << "";
   cout << "yyyyy" << " " << file << endl;
    //FILE * file = fopen (filename.c_str(), "w");
    fprintf(file, "%s,",a->type.c_str());
//    cout << "yoyo" << " " << " mai print krunga" << endl;
    switch(switchItem[a->type]){
        case 1:{ string* tmp = (string  *)(a->value);
                 cout << *tmp << endl;
                 fprintf(file, "%s, %lld,%lld \n", (*tmp).c_str(), a->size, a->offset);
                 break;
               }
        case 2:{ int* tmp = (int  *)(a->value);
                 fprintf(file, "%d, %lld,%lld \n", *tmp, a->size, a->offset);
                 cout << *tmp << endl;
                 break;
                }
        case 3:{
                 fprintf(file, "This is a function,");
                 fprintf(file, "%lld, %lld\n", a->size, a->offset);

               }
    } //cout << (int)switchitem[a->type] << endl;
 //   cout << "yoyo" << " " << " maine print kra" << endl;

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

void printSymTables(symTable* a, string filename) {
  FILE* file = fopen(filename.c_str(), "w");
  for(auto it: *a ){
//    cout << it.first.c_str()  << "filefilefile " << it.second->type<< endl;
    if (it.second->type.compare("func")==0){
 //     cout << "I am inside" << endl;
       filename = it.first+ ".csv";
     // FILE *f1 = fopen (filename.c_str(), "w");
      printSymTables(((symTable*)it.second->value), filename );
      //fclose(f1);
    }
    fprintf(file, "%s,", it.first.c_str());
    fprintStruct(it.second, file);    
  }
  fclose(file);
}

