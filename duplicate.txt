/* C program for exponent series */ 
/* taken from www.c4learn.com/c-programs/c-program-to-find-exponent-power-series.html */
int bor = 12;
int main() {
   int n, count;
   float x, term, sum;
 
   printf("\nEnter value of x :");
   scanf("%f", &x);
 
   n = term = sum = count = 1;
 
   while (n <= 100) {

      term = term *x / n;
      sum = sum + term;
      count = count + 1;
       int u =1;
      char *h;
      if (term < ACCURACY)
         n = 999;
      else
         n = n + 1;
   }
 
   printf("\nTerms = %d Sum = %f", count, sum);
   return 0;
}

