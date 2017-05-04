
int indexOf(int r, int c, int i, int j) {
  return i*r + j;
}

int main() {

  int a[100], b[100], c[100];
  int r1, c1, r2, c2, idx;
  int i, j, k=0;

  //scanmat(a0, &r1, &c1);
  prints("Input matrix size (m,n) ");
  r1 = scanf(); c1 = scanf();
  prints("Enter matrix elements:\n");
  for (i=0; i<r1; i=i+1) {
    for (j=0; j<c1; j=j+1) {
      idx = indexOf(r1, c1, i, j);
      a[idx] = scanf();
    }
  }

  //scanmat(b0, &r2, &c2);
  prints("Input matrix size (m,n) ");
  r2 = scanf(); c2 = scanf();
  prints("Enter matrix elements:\n");
  for (i=0; i<r2; i=i+1) {
    for (j=0; j<c2; j=j+1) {
      idx = indexOf(r2, c2, i, j);
      b[idx] = scanf();
    }
  }

  //matmul(a0, r1, c1, b0, c2, c0);
  int na, nb, nc;
  for (i=0; i<r1; i=i+1) {
    for (j=0; j<c2; j=j+1) {
      nc = indexOf(r1, c2, i, j);
      c[nc] = 0;
      for (k=0; k<c1; k=k+1) {
        na = indexOf(r1, c1, i, k);
        nb = indexOf(c1, c2, k, j);
        c[nc] += a[na]*b[nb];
      }
    }
  }  

  prints("Matrix product:\n");
  //printmat(c0, r1, c2);
  for (i=0; i<r1; i=i+1) {
    for (j=0; j<c2; j=j+1) {
      idx = indexOf(r1, c2, i, j);
      printn(c[idx]);prints(" ");
    }
    prints("\n");
  }

  return 0;
}
