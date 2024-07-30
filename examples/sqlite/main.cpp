#include <iostream>
#include <sqlite3.h>


int main(int,char**) {
  std::cout << sqlite3_libversion() << "\n";
  return 0;
}
