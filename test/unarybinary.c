int main() {
  int n;
  n = -1;     // -1
  n *= -1;    //  1
  n = n + 5;  //  6
  n = -n;     // -6
  n = n / -2; //  3
  n = n + -1; //  2
  prints("n = ");
  printf(n);
  if (n == 2) {
    prints("Test successful\n");
  } else {
    prints("Test failed\n");
  }
  return 0;
}
