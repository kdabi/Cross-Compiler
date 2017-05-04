int main() {
  int *a;
  int b =1;
  int c = 0;
  if (b || (b/0)) {
    prints("Test 1: (1 || (1/0)) => passed\n");
  }
  if (c && (b/c)) { }
  else {
    prints("Test 2: (0 && (1/0)) => passed\n");
  }
  return 0;
}
