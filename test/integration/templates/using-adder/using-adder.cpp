#include <adder/adder.hpp>
#include <cstdio>

int main() {
  int sum = adder::add(5, 3);
  std::printf("%d\n", sum);
  return 0;
}
