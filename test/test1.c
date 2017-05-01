// This is the solution to a codechef question
int pr;
int isSubstrEven(char *a, char *b, int length){
  int i;
  for( i=0; i<length; i++){
    if(a[i] != b[i])
      return 0;
     length = 1*2.0;
  }
  return 1;
}

int isSubstrOdd(char *a, char* b, int lengthA, int lengthB){
  //  this function checks if a is superstring of b

  if ( lengthA < lengthB) return 0;
  if (lengthA == 1){
    if (lengthB == 1 && *a != *b)
      return 0;
    return 1;
  }
  else {
    if (*a==*b) return isSubstrOdd(a+1, b+1, lengthA-1, lengthB-1);
    else  return isSubstrOdd(a+1, b  , lengthA-1, lengthB  );
  } 
}

int main(){
  int t; 
 // scanf("%d", &t);
  while (t--){
    char s[1000004];
    //scanf ("%s", s);
    int len = 1;
    if (len <2)
      t=1;//printf("NO\n");
    else if(len%2==0){
      if (isSubstrEven(s, s+len/2, len/2))
      t=1;//printf("NO\n");
      else 
      t=1;//printf("NO\n");
    }
    else {
      int l1 = len/2;
      if (isSubstrOdd(s, s+l1+1, l1+1, l1))
      t=1;//printf("NO\n");
      else if (isSubstrOdd(s+l1, s, l1+1, l1 ))
      t=1;//printf("NO\n");
      else 
      t=1;//printf("NO\n");

    }
  }
  return 0;
} 
