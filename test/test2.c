// This is an example on struct
// Has been picked from :
// http://fresh2refresh.com/c-programming/c-structures/
struct student 
{
  int id;
  char name[20];
  float percentage;
} record;

int main() 
{

  record.id=1;
  strcpy(record.name, "Raju");
  record.percentage = 86.5;

  printf(" Id is: %d \n", record.id);
  printf(" Name is: %s \n", record.name);
  printf(" Percentage is: %f \n", record.percentage);
  return 0;
}
