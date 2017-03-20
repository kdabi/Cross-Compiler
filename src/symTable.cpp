#include "symTable.h"

map<symTable *, symTable*> tParent;
map<symTable *, int> symTable_type;
map<string ,int> switchItem;
map<int, string> statusMap;

symTable GST;
int is_next;
symTable *curr;

void switchItemMap(){
   statusMap.insert(make_pair<int, string>(1,"iVal"));
   statusMap.insert(make_pair<int, string>(2,"fVal"));
   statusMap.insert(make_pair<int, string>(3,"dVal"));
   statusMap.insert(make_pair<int, string>(4,"sVal"));
   statusMap.insert(make_pair<int, string>(5,"cVal"));
   statusMap.insert(make_pair<int, string>(6,"bVal"));
   switchItem.insert(make_pair<string, int>("string", 1));
   switchItem.insert(make_pair<string, int>("int", 2));
   switchItem.insert(make_pair<string, int>("func", 3));
   switchItem.insert(make_pair<string, int>("Keyword", 1));
   switchItem.insert(make_pair<string, int>("Operator",1));
   switchItem.insert(make_pair<string, int>("IDENTIFIER", 1));
   switchItem.insert(make_pair<string, int>("ENUMERATION_CONSTANT", 1));
   switchItem.insert(make_pair<string, int>("TYPEDEF_NAME", 1));
}

void stInitialize(){
    switchItemMap();
    tParent.insert(make_pair<symTable*, symTable*>(&GST, NULL));
    symTable_type.insert(make_pair<symTable*, int>(&GST, 1));
    curr = &GST;
    is_next = 0;
    addKeywords();
}
void paramTable(){   
      makeSymTable(string("Next"),S_FUNC,string(""));
      is_next=1;
}

sEntry* makeEntry(string type,ull size,ll offset,int isInit){
    sEntry* mynew = new sEntry();
    mynew->type = type;
    mynew->size = size;
    mynew->offset = offset;
    mynew->is_init = isInit;
    return mynew;
}

string returnSymType(string key){
    sEntry* temp = lookup(key);
    if(temp){ string a = temp->type;return a;}
    else return string();
}

void insertSymbol(symTable& table,string key,string type,ull size,ll offset, int isInit){
   table.insert (pair<string,sEntry *>(key,makeEntry(type,size,offset,isInit)));
   return;
}

void fprintStruct(sEntry *a, FILE* file){
   // cout << a->type << " " << "";
    fprintf(file, "%s,",a->type.c_str());
    switch(switchItem[a->type]){
        case 1:{ 
  //               cout << *tmp << endl;
                 fprintf(file, " %lld,%lld,%d\n", a->size, a->offset,a->is_init);
                 break;
               }
        case 2:{ //int* tmp = (int  *)(a->value);
                 fprintf(file, "%lld,%lld ,%d\n", a->size, a->offset,a->is_init);
    //             cout << *tmp << endl;
                 break;
                }
        case 3:{
               //  fprintf(file, "This is a function,");
                 fprintf(file, "%lld, %lld,%d\n", a->size, a->offset,a->is_init); break;

               }
       default : {
                 //fprintf(file, "NULL,");
                 fprintf(file, "%lld, %lld, %d\n", a->size, a->offset,a->is_init);

               }

    }

}

void makeSymTable(string name,int type,string funcType){
  string f ;
  if(funcType!="12345") f =string("FUNC_")+funcType; else f = string("Block");
  if(is_next==1){ insertSymbol(*tParent[curr],name,f,0,0,1); 
                  (*tParent[curr]).erase(string("Next"));   
       }
  else {
   symTable* myTable = new symTable;
    insertSymbol(*curr,name,f,0,0,1);
    tParent.insert(pair<symTable*, symTable*>(myTable,curr));
    symTable_type.insert(pair<symTable*, int>(myTable,type));
    curr = myTable; }
    is_next=0;
}

void updateSymTable(){
    curr = tParent[curr];
}

sEntry* lookup(string a){
   symTable * tmp;
   tmp = curr;
   while (1){
      if ((*tmp).count(a)){
         return (*tmp)[a];
      }
      if(tParent[tmp]!=NULL) tmp= tParent[tmp];
      else break;
   }
   return NULL;
}
/*
void updateKey(string key,void *val){
   sEntry *temp = lookup(key);
   if(temp){ temp->value = val;
       temp->is_init =1;
   }
}
*/
void update_isInit(string key){
   sEntry *temp = lookup(key);
   if(temp){
       temp->is_init =1;
   }
}

void printSymTables(symTable* a, string filename) {
  FILE* file = fopen(filename.c_str(), "w");
  fprintf( file,"Key,Type,Size,Offset,is_Initialized\n");


  for(auto it: *a ){
    fprintf( file,"%s,", it.first.c_str());
    fprintStruct(it.second, file);  
  }
  fclose(file);
}
void addKeywords(){

//-------------------inserting keywords-------------------------------------------
  { string *keyword = new string(); *keyword = "AUTO"; insertSymbol(*curr,"auto","Keyword",0,0,1); } // auto keyword
  { string *keyword = new string(); *keyword = "BREAK"; insertSymbol(*curr,"break","Keyword",0,0,1); } // break keyword
  { string *keyword = new string(); *keyword = "CASE"; insertSymbol(*curr,"case","Keyword",0,0,1); } // case keyword
  { string *keyword = new string(); *keyword = "CHAR"; insertSymbol(*curr,"char","Keyword",0,0,1); } // char keyword
  { string *keyword = new string(); *keyword = "CONST"; insertSymbol(*curr,"const","Keyword",0,0,1); } // const keyword
  { string *keyword = new string(); *keyword = "CONTINUE"; insertSymbol(*curr,"continue","Keyword",0,0,1); } // CONTINUE keyword
  { string *keyword = new string(); *keyword = "DEFAULT"; insertSymbol(*curr,"default","Keyword",0,0,1); } // default keyword
  { string *keyword = new string(); *keyword = "DO"; insertSymbol(*curr,"do","Keyword",0,0,1); } // do keyword
  { string *keyword = new string(); *keyword = "DOUBLE"; insertSymbol(*curr,"double","Keyword",0,0,1); } // double keyword
  { string *keyword = new string(); *keyword = "ELSE"; insertSymbol(*curr,"else","Keyword",0,0,1); } // else keyword
  { string *keyword = new string(); *keyword = "ENUM"; insertSymbol(*curr,"enum","Keyword",0,0,1); } // enum keyword
  { string *keyword = new string(); *keyword = "EXTERN"; insertSymbol(*curr,"extern","Keyword",0,0,1); } // extern keyword
  { string *keyword = new string(); *keyword = "FLOAT"; insertSymbol(*curr,"float","Keyword",0,0,1); } // float keyword
  { string *keyword = new string(); *keyword = "FOR"; insertSymbol(*curr,"for","Keyword",0,0,1); } // for keyword
  { string *keyword = new string(); *keyword = "GOTO"; insertSymbol(*curr,"goto","Keyword",0,0,1); } // goto keyword
  { string *keyword = new string(); *keyword = "IF"; insertSymbol(*curr,"if","Keyword",0,0,1); } // if keyword
  { string *keyword = new string(); *keyword = "INLINE"; insertSymbol(*curr,"inline","Keyword",0,0,1); } // inline keyword
  { string *keyword = new string(); *keyword = "INT"; insertSymbol(*curr,"int","Keyword",0,0,1); } // int keyword
  { string *keyword = new string(); *keyword = "LONG"; insertSymbol(*curr,"long","Keyword",0,0,1); } // long keyword
  { string *keyword = new string(); *keyword = "REGISTER"; insertSymbol(*curr,"register","Keyword",0,0,1); } // register keyword
  {string *keyword = new string();  *keyword = "RESTRICT"; insertSymbol(*curr,"restrict","Keyword",0,0,1); } // restrict keyword
  {string *keyword = new string();  *keyword = "RETURN"; insertSymbol(*curr,"return","Keyword",0,0,1); } // return keyword
  {string *keyword = new string();  *keyword = "SHORT"; insertSymbol(*curr,"short","Keyword",0,0,1); } // short keyword
  {string *keyword = new string();  *keyword = "SIGNED"; insertSymbol(*curr,"signed","Keyword",0,0,1); } // signed keyword
  {string *keyword = new string();  *keyword = "SIZEOF"; insertSymbol(*curr,"sizeof","Keyword",0,0,1); } // sizeof keyword
  {string *keyword = new string();  *keyword = "STATIC"; insertSymbol(*curr,"static","Keyword",0,0,1); } // static keyword
  {string *keyword = new string();  *keyword = "STRUCT"; insertSymbol(*curr,"struct","Keyword",0,0,1); } // struct keyword
  {string *keyword = new string();  *keyword = "SWITCH"; insertSymbol(*curr,"switch","Keyword",0,0,1); } // switch keyword
  {string *keyword = new string();  *keyword = "TYPEDEF"; insertSymbol(*curr,"typedef","Keyword",0,0,1); } // typedef keyword
  {string *keyword = new string();  *keyword = "UNION"; insertSymbol(*curr,"union","Keyword",0,0,1); } // union keyword
  {string *keyword = new string();  *keyword = "UNSIGNED"; insertSymbol(*curr,"unsigned","Keyword",0,0,1); } // unsigned keyword
  {string *keyword = new string();  *keyword = "VOID"; insertSymbol(*curr,"void","Keyword",0,0,1); } // void keyword
  {string *keyword = new string();  *keyword = "VOLATILE"; insertSymbol(*curr,"volatile","Keyword",0,0,1); } // volatile keyword
  {string *keyword = new string();  *keyword = "WHILE"; insertSymbol(*curr,"while","Keyword",0,0,1); } // while keyword
  {string *keyword = new string();  *keyword = "ALIGNAS"; insertSymbol(*curr,"_Alignas","Keyword",0,0,1); } // _Alignas keyword
  {string *keyword = new string();  *keyword = "ALIGNOF"; insertSymbol(*curr,"_Alignof","Keyword",0,0,1); } // _Alignof keyword
  {string *keyword = new string();  *keyword = "ATOMIC"; insertSymbol(*curr,"_Atomic","Keyword",0,0,1); } // _Atomic keyword
  {string *keyword = new string();  *keyword = "BOOL"; insertSymbol(*curr,"_Bool","Keyword",0,0,1); } // _Bool keyword
  {string *keyword = new string();  *keyword = "COMPLEX"; insertSymbol(*curr,"_Complex","Keyword",0,0,1); } // _Complex keyword
  {string *keyword = new string();  *keyword = "GENERIC"; insertSymbol(*curr,"_Generic","Keyword",0,0,1); } // _Generic keyword
  {string *keyword = new string();  *keyword = "IMAGINARY"; insertSymbol(*curr,"_Imaginary","Keyword",0,0,1); } // _Imaginary keyword
  {string *keyword = new string();  *keyword = "NORETURN"; insertSymbol(*curr,"_Noreturn","Keyword",0,0,1); } // _Noreturn keyword
  {string *keyword = new string();  *keyword = "STATIC_ASSERT"; insertSymbol(*curr,"_Static_assert","Keyword",0,0,1); } // _Static_assert keyword
  {string *keyword = new string();  *keyword = "THREAD_LOCAL"; insertSymbol(*curr,"_Thread_local","Keyword",0,0,1); } // _Thread_local keyword
  {string *keyword = new string();  *keyword = "FUNC_NAME"; insertSymbol(*curr,"__func__","Keyword",0,0,1); } // __func__ keyword

//-----------------------------inserting operators---------------------------------------------------

  {string *oper = new string();  *oper = "ELLIPSIS"; insertSymbol(*curr,"...","Operator",0,0,1); } // ... operator
  {string *oper = new string();  *oper = "RIGHT_ASSIGN"; insertSymbol(*curr,">>==","Operator",0,0,1); } // >>== operator
  {string *oper = new string();  *oper = "LEFT_ASSIGN"; insertSymbol(*curr,"<<==","Operator",0,0,1); } // <<== operator
  {string *oper = new string();  *oper = "ADD_ASSIGN"; insertSymbol(*curr,"+=","Operator",0,0,1); } // += operator
  {string *oper = new string();  *oper = "SUB_ASSIGN"; insertSymbol(*curr,"-=","Operator",0,0,1); } // -= operator
  {string *oper = new string();  *oper = "MUL_ASSIGN"; insertSymbol(*curr,"*=","Operator",0,0,1); } // *= operator
  {string *oper = new string();  *oper = "DIV_ASSIGN"; insertSymbol(*curr,"/=","Operator",0,0,1); } // /= operator
  {string *oper = new string();  *oper = "MOD_ASSIGN"; insertSymbol(*curr,"%=","Operator",0,0,1); } // %= operator
  {string *oper = new string();  *oper = "AND_ASSIGN"; insertSymbol(*curr,"&=","Operator",0,0,1); } // &= operator
  {string *oper = new string();  *oper = "XOR_ASSIGN"; insertSymbol(*curr,"^=","Operator",0,0,1); } // ^= operator
  {string *oper = new string();  *oper = "OR_ASSIGN"; insertSymbol(*curr,"|=","Operator",0,0,1); } // |= operator
  {string *oper = new string();  *oper = "RIGHT_OP"; insertSymbol(*curr,">>","Operator",0,0,1); } // >> operator
  {string *oper = new string();  *oper = "LEFT_OP"; insertSymbol(*curr,"<<","Operator",0,0,1); } // << operator
  {string *oper = new string();  *oper = "INC_OP"; insertSymbol(*curr,"++","Operator",0,0,1); } // ++ operator
  {string *oper = new string();  *oper = "DEC_OP"; insertSymbol(*curr,"--","Operator",0,0,1); } // -- operator
  {string *oper = new string();  *oper = "PTR_OP"; insertSymbol(*curr,"->","Operator",0,0,1); } // -> operator
  {string *oper = new string();  *oper = "AND_OP"; insertSymbol(*curr,"&&","Operator",0,0,1); } // && operator
  {string *oper = new string();  *oper = "OR_OP"; insertSymbol(*curr,"||","Operator",0,0,1); } // || operator
  {string *oper = new string();  *oper = "LE_OP"; insertSymbol(*curr,"<=","Operator",0,0,1); } // <= operator
  {string *oper = new string();  *oper = "GE_OP"; insertSymbol(*curr,">=","Operator",0,0,1); } // >= operator
  {string *oper = new string();  *oper = "EQ_OP"; insertSymbol(*curr,"\=\=","Operator",0,0,1); } // == operator
  {string *oper = new string();  *oper = "NE_OP"; insertSymbol(*curr,"!=","Operator",0,0,1); } // != operator
  {string *oper = new string();  *oper = ";"; insertSymbol(*curr,";","Operator",0,0,1); } // ; operator
  {string *oper = new string();  *oper = "{"; insertSymbol(*curr,"{","Operator",0,0,1); } // { operator
  {string *oper = new string();  *oper = "{"; insertSymbol(*curr,"<%","Operator",0,0,1); } // <% operator
  {string *oper = new string();  *oper = "}"; insertSymbol(*curr,"}","Operator",0,0,1); } // } operator
  {string *oper = new string();  *oper = "}"; insertSymbol(*curr,"%>","Operator",0,0,1); } // %> operator
  {string *oper = new string();  *oper = ","; insertSymbol(*curr,",","Operator",0,0,1); } // , operator
  {string *oper = new string();  *oper = ":"; insertSymbol(*curr,":","Operator",0,0,1); } // : operator
  {string *oper = new string();  *oper = "="; insertSymbol(*curr,"=","Operator",0,0,1); } // = operator
  {string *oper = new string();  *oper = "("; insertSymbol(*curr,"(","Operator",0,0,1); } // ( operator
  {string *oper = new string();  *oper = ")"; insertSymbol(*curr,")","Operator",0,0,1); } // ) operator
  {string *oper = new string();  *oper = "["; insertSymbol(*curr,"[","Operator",0,0,1); } // [ operator
  {string *oper = new string();  *oper = "["; insertSymbol(*curr,"<:","Operator",0,0,1); } // <: operator
  {string *oper = new string();  *oper = "]"; insertSymbol(*curr,":>","Operator",0,0,1); } // :> operator
  {string *oper = new string();  *oper = "]"; insertSymbol(*curr,"]","Operator",0,0,1); } // ] operator
  {string *oper = new string();  *oper = "."; insertSymbol(*curr,".","Operator",0,0,1); } // . operator
  {string *oper = new string();  *oper = "&"; insertSymbol(*curr,"&","Operator",0,0,1); } // & operator
  {string *oper = new string();  *oper = "!"; insertSymbol(*curr,"!","Operator",0,0,1); } // ! operator
  {string *oper = new string();  *oper = "~"; insertSymbol(*curr,"~","Operator",0,0,1); } // ~ operator
  {string *oper = new string();  *oper = "-"; insertSymbol(*curr,"-","Operator",0,0,1); } // - operator
  {string *oper = new string();  *oper = "+"; insertSymbol(*curr,"+","Operator",0,0,1); } // + operator
  {string *oper = new string();  *oper = "*"; insertSymbol(*curr,"*","Operator",0,0,1); } // * operator
  {string *oper = new string();  *oper = "/"; insertSymbol(*curr,"/","Operator",0,0,1); } // / operator
  {string *oper = new string();  *oper = "%"; insertSymbol(*curr,"%","Operator",0,0,1); } // % operator
  {string *oper = new string();  *oper = "<"; insertSymbol(*curr,"<","Operator",0,0,1); } // < operator
  {string *oper = new string();  *oper = ">"; insertSymbol(*curr,">","Operator",0,0,1); } // > operator
  {string *oper = new string();  *oper = "^"; insertSymbol(*curr,"^","Operator",0,0,1); } // ^ operator
  {string *oper = new string();  *oper = "|"; insertSymbol(*curr,"|","Operator",0,0,1); } // | operator
  {string *oper = new string();  *oper = "?"; insertSymbol(*curr,"?","Operator",0,0,1); } // ? operator

/////////////// basic printf, scanf, strlen :: to get the code running /////////
  insertSymbol(*curr,"printf","FUNC_ void",0,0,1); //
  insertSymbol(*curr,"scanf","FUNC_ void",0,0,1); //
  insertSymbol(*curr,"strlen","FUNC_ int",0,0,1); //

}
