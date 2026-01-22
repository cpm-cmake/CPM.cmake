#include <sqlite3.h>

#include <iostream>

int main(int, char**) {
  std::cout << sqlite3_libversion() << "\n";
  return 0;
}
