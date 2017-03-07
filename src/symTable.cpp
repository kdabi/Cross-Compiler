#include "symTable.h"

map<symTable *, symTable*> tParent;
map<string ,int> switchItem;

symTable GST;
symTable *curr;
string oper;

void switchItemMap(){
   switchItem.insert(make_pair<string, int>("string", 1));
   switchItem.insert(make_pair<string, int>("int", 2));
   switchItem.insert(make_pair<string, int>("func", 3));
   switchItem.insert(make_pair<string, int>("Keyword", 1));
   switchItem.insert(make_pair<string, int>("Operator",1));
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

//-------------------inserting keywords-------------------------------------------
  { string *keyword = new string(); *keyword = "AUTO"; insertSymbol(*curr,"auto","Keyword",keyword,0,0); } // auto keyword
  { string *keyword = new string(); *keyword = "BREAK"; insertSymbol(*curr,"break","Keyword",keyword,0,0); } // break keyword
  { string *keyword = new string(); *keyword = "CASE"; insertSymbol(*curr,"case","Keyword",keyword,0,0); } // case keyword
  { string *keyword = new string(); *keyword = "CHAR"; insertSymbol(*curr,"char","Keyword",keyword,0,0); } // char keyword
  { string *keyword = new string(); *keyword = "CONST"; insertSymbol(*curr,"const","Keyword",keyword,0,0); } // const keyword
  { string *keyword = new string(); *keyword = "CONTINUE"; insertSymbol(*curr,"continue","Keyword",keyword,0,0); } // CONTINUE keyword
  { string *keyword = new string(); *keyword = "DEFAULT"; insertSymbol(*curr,"default","Keyword",keyword,0,0); } // default keyword
  { string *keyword = new string(); *keyword = "DO"; insertSymbol(*curr,"do","Keyword",keyword,0,0); } // do keyword
  { string *keyword = new string(); *keyword = "DOUBLE"; insertSymbol(*curr,"double","Keyword",keyword,0,0); } // double keyword
  { string *keyword = new string(); *keyword = "ELSE"; insertSymbol(*curr,"else","Keyword",keyword,0,0); } // else keyword
  { string *keyword = new string(); *keyword = "ENUM"; insertSymbol(*curr,"enum","Keyword",keyword,0,0); } // enum keyword
  { string *keyword = new string(); *keyword = "EXTERN"; insertSymbol(*curr,"extern","Keyword",keyword,0,0); } // extern keyword
  { string *keyword = new string(); *keyword = "FLOAT"; insertSymbol(*curr,"float","Keyword",keyword,0,0); } // float keyword
  { string *keyword = new string(); *keyword = "FOR"; insertSymbol(*curr,"for","Keyword",keyword,0,0); } // for keyword
  { string *keyword = new string(); *keyword = "GOTO"; insertSymbol(*curr,"goto","Keyword",keyword,0,0); } // goto keyword
  { string *keyword = new string(); *keyword = "IF"; insertSymbol(*curr,"if","Keyword",keyword,0,0); } // if keyword
  { string *keyword = new string(); *keyword = "INLINE"; insertSymbol(*curr,"inline","Keyword",keyword,0,0); } // inline keyword
  { string *keyword = new string(); *keyword = "INT"; insertSymbol(*curr,"int","Keyword",keyword,0,0); } // int keyword
  { string *keyword = new string(); *keyword = "LONG"; insertSymbol(*curr,"long","Keyword",keyword,0,0); } // long keyword
  { string *keyword = new string(); *keyword = "REGISTER"; insertSymbol(*curr,"register","Keyword",keyword,0,0); } // register keyword
  {string *keyword = new string();  *keyword = "RESTRICT"; insertSymbol(*curr,"restrict","Keyword",keyword,0,0); } // restrict keyword
  {string *keyword = new string();  *keyword = "RETURN"; insertSymbol(*curr,"return","Keyword",keyword,0,0); } // return keyword
  {string *keyword = new string();  *keyword = "SHORT"; insertSymbol(*curr,"short","Keyword",keyword,0,0); } // short keyword
  {string *keyword = new string();  *keyword = "SIGNED"; insertSymbol(*curr,"signed","Keyword",keyword,0,0); } // signed keyword
  {string *keyword = new string();  *keyword = "SIZEOF"; insertSymbol(*curr,"sizeof","Keyword",keyword,0,0); } // sizeof keyword
  {string *keyword = new string();  *keyword = "STATIC"; insertSymbol(*curr,"static","Keyword",keyword,0,0); } // static keyword
  {string *keyword = new string();  *keyword = "STRUCT"; insertSymbol(*curr,"struct","Keyword",keyword,0,0); } // struct keyword
  {string *keyword = new string();  *keyword = "SWITCH"; insertSymbol(*curr,"switch","Keyword",keyword,0,0); } // switch keyword
  {string *keyword = new string();  *keyword = "TYPEDEF"; insertSymbol(*curr,"typedef","Keyword",keyword,0,0); } // typedef keyword
  {string *keyword = new string();  *keyword = "UNION"; insertSymbol(*curr,"union","Keyword",keyword,0,0); } // union keyword
  {string *keyword = new string();  *keyword = "UNSIGNED"; insertSymbol(*curr,"unsigned","Keyword",keyword,0,0); } // unsigned keyword
  {string *keyword = new string();  *keyword = "VOID"; insertSymbol(*curr,"void","Keyword",keyword,0,0); } // void keyword
  {string *keyword = new string();  *keyword = "VOLATILE"; insertSymbol(*curr,"volatile","Keyword",keyword,0,0); } // volatile keyword
  {string *keyword = new string();  *keyword = "WHILE"; insertSymbol(*curr,"while","Keyword",keyword,0,0); } // while keyword
  {string *keyword = new string();  *keyword = "ALIGNAS"; insertSymbol(*curr,"_Alignas","Keyword",keyword,0,0); } // _Alignas keyword
  {string *keyword = new string();  *keyword = "ALIGNOF"; insertSymbol(*curr,"_Alignof","Keyword",keyword,0,0); } // _Alignof keyword
  {string *keyword = new string();  *keyword = "ATOMIC"; insertSymbol(*curr,"_Atomic","Keyword",keyword,0,0); } // _Atomic keyword
  {string *keyword = new string();  *keyword = "BOOL"; insertSymbol(*curr,"_Bool","Keyword",keyword,0,0); } // _Bool keyword
  {string *keyword = new string();  *keyword = "COMPLEX"; insertSymbol(*curr,"_Complex","Keyword",keyword,0,0); } // _Complex keyword
  {string *keyword = new string();  *keyword = "GENERIC"; insertSymbol(*curr,"_Generic","Keyword",keyword,0,0); } // _Generic keyword
  {string *keyword = new string();  *keyword = "IMAGINARY"; insertSymbol(*curr,"_Imaginary","Keyword",keyword,0,0); } // _Imaginary keyword
  {string *keyword = new string();  *keyword = "NORETURN"; insertSymbol(*curr,"_Noreturn","Keyword",keyword,0,0); } // _Noreturn keyword
  {string *keyword = new string();  *keyword = "STATIC_ASSERT"; insertSymbol(*curr,"_Static_assert","Keyword",keyword,0,0); } // _Static_assert keyword
  {string *keyword = new string();  *keyword = "THREAD_LOCAL"; insertSymbol(*curr,"_Thread_local","Keyword",keyword,0,0); } // _Thread_local keyword
  {string *keyword = new string();  *keyword = "FUNC_NAME"; insertSymbol(*curr,"__func__","Keyword",keyword,0,0); } // __func__ keyword

//-----------------------------inserting operators---------------------------------------------------

  {string *oper = new string();  *oper = "ELLIPSIS"; insertSymbol(*curr,"...","Operator",oper,0,0); } // ... operator
  {string *oper = new string();  *oper = "RIGHT_ASSIGN"; insertSymbol(*curr,">>==","Operator",oper,0,0); } // >>== operator
  {string *oper = new string();  *oper = "LEFT_ASSIGN"; insertSymbol(*curr,"<<==","Operator",oper,0,0); } // <<== operator
  {string *oper = new string();  *oper = "ADD_ASSIGN"; insertSymbol(*curr,"+=","Operator",oper,0,0); } // += operator
  {string *oper = new string();  *oper = "SUB_ASSIGN"; insertSymbol(*curr,"-=","Operator",oper,0,0); } // -= operator
  {string *oper = new string();  *oper = "MUL_ASSIGN"; insertSymbol(*curr,"*=","Operator",oper,0,0); } // *= operator
  {string *oper = new string();  *oper = "DIV_ASSIGN"; insertSymbol(*curr,"/=","Operator",oper,0,0); } // /= operator
  {string *oper = new string();  *oper = "MOD_ASSIGN"; insertSymbol(*curr,"%=","Operator",oper,0,0); } // %= operator
  {string *oper = new string();  *oper = "AND_ASSIGN"; insertSymbol(*curr,"&=","Operator",oper,0,0); } // &= operator
  {string *oper = new string();  *oper = "XOR_ASSIGN"; insertSymbol(*curr,"^=","Operator",oper,0,0); } // ^= operator
  {string *oper = new string();  *oper = "OR_ASSIGN"; insertSymbol(*curr,"|=","Operator",oper,0,0); } // |= operator
  {string *oper = new string();  *oper = "RIGHT_OP"; insertSymbol(*curr,">>","Operator",oper,0,0); } // >> operator
  {string *oper = new string();  *oper = "LEFT_OP"; insertSymbol(*curr,"<<","Operator",oper,0,0); } // << operator
  {string *oper = new string();  *oper = "INC_OP"; insertSymbol(*curr,"++","Operator",oper,0,0); } // ++ operator
  {string *oper = new string();  *oper = "DEC_OP"; insertSymbol(*curr,"--","Operator",oper,0,0); } // -- operator
  {string *oper = new string();  *oper = "PTR_OP"; insertSymbol(*curr,"->","Operator",oper,0,0); } // -> operator
  {string *oper = new string();  *oper = "AND_OP"; insertSymbol(*curr,"&&","Operator",oper,0,0); } // && operator
  {string *oper = new string();  *oper = "OR_OP"; insertSymbol(*curr,"||","Operator",oper,0,0); } // || operator
  {string *oper = new string();  *oper = "LE_OP"; insertSymbol(*curr,"<=","Operator",oper,0,0); } // <= operator
  {string *oper = new string();  *oper = "GE_OP"; insertSymbol(*curr,">=","Operator",oper,0,0); } // >= operator
  {string *oper = new string();  *oper = "EQ_OP"; insertSymbol(*curr,"==","Operator",oper,0,0); } // == operator
  {string *oper = new string();  *oper = "NE_OP"; insertSymbol(*curr,"!=","Operator",oper,0,0); } // != operator
  {string *oper = new string();  *oper = ";"; insertSymbol(*curr,";","Operator",oper,0,0); } // ; operator
  {string *oper = new string();  *oper = "{"; insertSymbol(*curr,"{","Operator",oper,0,0); } // { operator
  {string *oper = new string();  *oper = "{"; insertSymbol(*curr,"<%","Operator",oper,0,0); } // <% operator
  {string *oper = new string();  *oper = "}"; insertSymbol(*curr,"}","Operator",oper,0,0); } // } operator
  {string *oper = new string();  *oper = "}"; insertSymbol(*curr,"%>","Operator",oper,0,0); } // %> operator
  {string *oper = new string();  *oper = ","; insertSymbol(*curr,",","Operator",oper,0,0); } // , operator
  {string *oper = new string();  *oper = ":"; insertSymbol(*curr,":","Operator",oper,0,0); } // : operator
  {string *oper = new string();  *oper = "="; insertSymbol(*curr,"=","Operator",oper,0,0); } // = operator
  {string *oper = new string();  *oper = "("; insertSymbol(*curr,"(","Operator",oper,0,0); } // ( operator
  {string *oper = new string();  *oper = ")"; insertSymbol(*curr,")","Operator",oper,0,0); } // ) operator
  {string *oper = new string();  *oper = "["; insertSymbol(*curr,"[","Operator",oper,0,0); } // [ operator
  {string *oper = new string();  *oper = "["; insertSymbol(*curr,"<:","Operator",oper,0,0); } // <: operator
  {string *oper = new string();  *oper = "]"; insertSymbol(*curr,":>","Operator",oper,0,0); } // :> operator
  {string *oper = new string();  *oper = "]"; insertSymbol(*curr,"]","Operator",oper,0,0); } // ] operator
  {string *oper = new string();  *oper = "."; insertSymbol(*curr,".","Operator",oper,0,0); } // . operator
  {string *oper = new string();  *oper = "&"; insertSymbol(*curr,"&","Operator",oper,0,0); } // & operator
  {string *oper = new string();  *oper = "!"; insertSymbol(*curr,"!","Operator",oper,0,0); } // ! operator
  {string *oper = new string();  *oper = "~"; insertSymbol(*curr,"~","Operator",oper,0,0); } // ~ operator
  {string *oper = new string();  *oper = "-"; insertSymbol(*curr,"-","Operator",oper,0,0); } // - operator
  {string *oper = new string();  *oper = "+"; insertSymbol(*curr,"+","Operator",oper,0,0); } // + operator
  {string *oper = new string();  *oper = "*"; insertSymbol(*curr,"*","Operator",oper,0,0); } // * operator
  {string *oper = new string();  *oper = "/"; insertSymbol(*curr,"/","Operator",oper,0,0); } // / operator
  {string *oper = new string();  *oper = "%"; insertSymbol(*curr,"%","Operator",oper,0,0); } // % operator
  {string *oper = new string();  *oper = "<"; insertSymbol(*curr,"<","Operator",oper,0,0); } // < operator
  {string *oper = new string();  *oper = ">"; insertSymbol(*curr,">","Operator",oper,0,0); } // > operator
  {string *oper = new string();  *oper = "^"; insertSymbol(*curr,"^","Operator",oper,0,0); } // ^ operator
  {string *oper = new string();  *oper = "|"; insertSymbol(*curr,"|","Operator",oper,0,0); } // | operator
  {string *oper = new string();  *oper = "?"; insertSymbol(*curr,"?","Operator",oper,0,0); } // ? operator

}
