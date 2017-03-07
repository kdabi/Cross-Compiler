#include "symTable.h"

map<symTable *, symTable*> tParent;
map<string ,int> switchItem;

symTable GST;
symTable *curr;
string keyword ;

void switchItemMap(){
   switchItem.insert(make_pair<string, int>("string", 1));
   switchItem.insert(make_pair<string, int>("int", 2));
   switchItem.insert(make_pair<string, int>("func", 3));
   switchItem.insert(make_pair<string, int>("Keyword", 1));
}

void stInitialize(){
    switchItemMap();
    tParent.insert(make_pair<symTable*, symTable*>(&GST, NULL));
    curr = &GST;
    addKeywords();
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
   // cout << a->type << " " << "";
    fprintf(file, "%s,",a->type.c_str());
    switch(switchItem[a->type]){
        case 1:{ string* tmp = (string  *)(a->value);
  //               cout << *tmp << endl;
                 fprintf(file, "%s, %lld,%lld \n", (*tmp).c_str(), a->size, a->offset);
                 break;
               }
        case 2:{ int* tmp = (int  *)(a->value);
                 fprintf(file, "%d, %lld,%lld \n", *tmp, a->size, a->offset);
    //             cout << *tmp << endl;
                 break;
                }
        case 3:{
                 fprintf(file, "This is a function,");
                 fprintf(file, "%lld, %lld\n", a->size, a->offset);

               }
    }

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
      }
      if(tParent[tmp]!=NULL) tmp= tParent[tmp];
      else break;
   }
   return NULL;
}

void printSymTables(symTable* a, string filename) {
  FILE* file = fopen(filename.c_str(), "w");
  for(auto it: *a ){
    fprintf(file, "%s,", it.first.c_str());
    fprintStruct(it.second, file);    
  }
  fclose(file);
}
void addKeywords(){
  { keyword = "AUTO"; insertSymbol(*curr,"auto","Keyword",&keyword,0,0); } // auto keyword
  { keyword = "BREAK"; insertSymbol(*curr,"break","Keyword",&keyword,0,0); } // break keyword
  { keyword = "CASE"; insertSymbol(*curr,"case","Keyword",&keyword,0,0); } // case keyword
  { keyword = "CHAR"; insertSymbol(*curr,"char","Keyword",&keyword,0,0); } // char keyword
  { keyword = "CONST"; insertSymbol(*curr,"const","Keyword",&keyword,0,0); } // const keyword
  { keyword = "CONTINUE"; insertSymbol(*curr,"continue","Keyword",&keyword,0,0); } // CONTINUE keyword
  { keyword = "DEFAULT"; insertSymbol(*curr,"default","Keyword",&keyword,0,0); } // default keyword
  { keyword = "DO"; insertSymbol(*curr,"do","Keyword",&keyword,0,0); } // do keyword
  { keyword = "DOUBLE"; insertSymbol(*curr,"double","Keyword",&keyword,0,0); } // double keyword
  { keyword = "ELSE"; insertSymbol(*curr,"else","Keyword",&keyword,0,0); } // else keyword
  { keyword = "ENUM"; insertSymbol(*curr,"enum","Keyword",&keyword,0,0); } // enum keyword
  { keyword = "EXTERN"; insertSymbol(*curr,"extern","Keyword",&keyword,0,0); } // extern keyword
  { keyword = "FLOAT"; insertSymbol(*curr,"float","Keyword",&keyword,0,0); } // float keyword
  { keyword = "FOR"; insertSymbol(*curr,"for","Keyword",&keyword,0,0); } // for keyword
  { keyword = "GOTO"; insertSymbol(*curr,"goto","Keyword",&keyword,0,0); } // goto keyword
  { keyword = "IF"; insertSymbol(*curr,"if","Keyword",&keyword,0,0); } // if keyword
  { keyword = "INLINE"; insertSymbol(*curr,"inline","Keyword",&keyword,0,0); } // inline keyword
  { keyword = "INT"; insertSymbol(*curr,"int","Keyword",&keyword,0,0); } // int keyword
  { keyword = "LONG"; insertSymbol(*curr,"long","Keyword",&keyword,0,0); } // long keyword
  { keyword = "REGISTER"; insertSymbol(*curr,"register","Keyword",&keyword,0,0); } // register keyword
  { keyword = "RESTRICT"; insertSymbol(*curr,"restrict","Keyword",&keyword,0,0); } // restrict keyword
  { keyword = "RETURN"; insertSymbol(*curr,"return","Keyword",&keyword,0,0); } // return keyword
  { keyword = "SHORT"; insertSymbol(*curr,"short","Keyword",&keyword,0,0); } // short keyword
  { keyword = "SIGNED"; insertSymbol(*curr,"signed","Keyword",&keyword,0,0); } // signed keyword
  { keyword = "SIZEOF"; insertSymbol(*curr,"sizeof","Keyword",&keyword,0,0); } // sizeof keyword
  { keyword = "STATIC"; insertSymbol(*curr,"static","Keyword",&keyword,0,0); } // static keyword
  { keyword = "STRUCT"; insertSymbol(*curr,"struct","Keyword",&keyword,0,0); } // struct keyword
  { keyword = "SWITCH"; insertSymbol(*curr,"switch","Keyword",&keyword,0,0); } // switch keyword
  { keyword = "TYPEDEF"; insertSymbol(*curr,"typedef","Keyword",&keyword,0,0); } // typedef keyword
  { keyword = "UNION"; insertSymbol(*curr,"union","Keyword",&keyword,0,0); } // union keyword
  { keyword = "UNSIGNED"; insertSymbol(*curr,"unsigned","Keyword",&keyword,0,0); } // unsigned keyword
  { keyword = "VOID"; insertSymbol(*curr,"void","Keyword",&keyword,0,0); } // void keyword
  { keyword = "VOLATILE"; insertSymbol(*curr,"volatile","Keyword",&keyword,0,0); } // volatile keyword
  { keyword = "WHILE"; insertSymbol(*curr,"while","Keyword",&keyword,0,0); } // while keyword
  { keyword = "ALIGNAS"; insertSymbol(*curr,"_Alignas","Keyword",&keyword,0,0); } // _Alignas keyword
  { keyword = "ALIGNOF"; insertSymbol(*curr,"_Alignof","Keyword",&keyword,0,0); } // _Alignof keyword
  { keyword = "ATOMIC"; insertSymbol(*curr,"_Atomic","Keyword",&keyword,0,0); } // _Atomic keyword
  { keyword = "BOOL"; insertSymbol(*curr,"_Bool","Keyword",&keyword,0,0); } // _Bool keyword
  { keyword = "COMPLEX"; insertSymbol(*curr,"_Complex","Keyword",&keyword,0,0); } // _Complex keyword
  { keyword = "GENERIC"; insertSymbol(*curr,"_Generic","Keyword",&keyword,0,0); } // _Generic keyword
  { keyword = "IMAGINARY"; insertSymbol(*curr,"_Imaginary","Keyword",&keyword,0,0); } // _Imaginary keyword
  { keyword = "NORETURN"; insertSymbol(*curr,"_Noreturn","Keyword",&keyword,0,0); } // _Noreturn keyword
  { keyword = "STATIC_ASSERT"; insertSymbol(*curr,"_Static_assert","Keyword",&keyword,0,0); } // _Static_assert keyword
  { keyword = "THREAD_LOCAL"; insertSymbol(*curr,"_Thread_local","Keyword",&keyword,0,0); } // _Thread_local keyword
  { keyword = "FUNC_NAME"; insertSymbol(*curr,"__func__","Keyword",&keyword,0,0); } // __func__ keyword

}
