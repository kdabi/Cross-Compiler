
int bubble_sort(int* list, int n){
    long c,d;
    double t;
    
    for(c =0;c<n-1;c=c+1){
        for(d=0;d<n-c-1;d=d+1){
            if(list[d] > list[d+1] ){
                t = list[d];
                list[d] = list[d+1];
                list[d+1] = t;
            }
        }
    }
}


int main(){
    int arr[1000];
    int T ;
    int i,len;
    prints("Enter the number of test cases : ");
    T = scanf();
    while(T){
	T = T-1;
	prints("Enter the length of the array (<=1000) : ");
        len = scanf();
        for(i=0;i<len;i=i+1){
           arr[i] = scanf();
        }
	prints("Sorting the array............ \n");
        bubble_sort(arr, len);
        for(i=0;i<len;i=i+1){
           printn(arr[i]);
           prints("<>");
        }
	prints("\n");
    }
    return 0;
}
