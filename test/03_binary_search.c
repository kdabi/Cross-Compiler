int main()
{
   int c, first, last, middle, n, search, array[100];
 
   prints("Enter number of elements\n");
   n = scanf();
 
   prints("Enter ");
   printn(n);
   prints(" integers\n");
 
   for (c = 0; c < n; c=c+1){
      array[c] = scanf();
   }
   prints("Enter value to find\n");
   search = scanf();
 
   first = 0;
   last = n - 1;
   middle = (first+last)/2;
 
   while (first <= last) {
      if (array[middle] < search)
         first = middle + 1;    
      else if (array[middle] == search) {
         printn(search);
         prints(" found at location ");
         printn(middle+1);
         prints("\n");
         break;
      }
      else
         last = middle - 1;
 
      middle = (first + last)/2;
   }
   if (first > last){
      prints("Not found! ");
      printn(search);
      prints(" is not present in the list.\n");
  }
 
   return 0;   
}
