int main(){
  int k = 1;
a:
  printf(k);
  goto b;
b:
  goto c;
c: 
  goto d;
d:
  goto e;
e:
  k=k+1;
  if(k<10)
        goto a;
  return 0;
}
