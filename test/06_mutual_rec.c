int absolute(int x){
 if(x < 0) return -x;
 return x;
}
int odd(int number){}
int even(int number){}

int main() {
  int T; 
  T = scanf();
  while (T) {
    T = T-1;
    int n; 
    n = scanf();
    prints("odd: ");
    printf(odd(n));
    prints("even: ");
    printf(even(n));
  }
  return 0;
}

int even(int number) {    
  if (number == 0)
    return 1;
  else
    return odd(absolute(number)-1);
}

int odd(int number) {
  if (number == 0)
    return 0;
  else
    return even(absolute(number)-1);
}


