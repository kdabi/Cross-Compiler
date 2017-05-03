/*
int ackermann(int a,int l){
    prints("i'm in ackermann");
    printf(a);
    printf(l);
    if(a == 0)
      return l+1;
    if((a>0) && (l == 0))
      return ackermann(a-1,1);
    if( a>0 && l>0){ 
      int k = ackermann(a,l-1);
      return ackermann(a-1,k);}
      return 1;
}
*/
#define abs(x) (-(x))
int main(){
       //int m=scanf();//int n=scanf();
       int m = -1;
       int n = 2;
	printf(abs(m));
       //int* a =  &m; printf(&m); printf(a);printf(*a);
       //int* b =  &n; printf(&n); printf(b);printf(*b);
       //int k = *a;
	//printf(m);
       //printf(k);
    return 0;
}
