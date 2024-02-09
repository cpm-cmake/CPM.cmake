#define CATCH_CONFIG_MAIN

#include <fibonacci.h>

#include <iostream>

int main() {
  std::cout << "fib(10) = " << fastFibonacci(10) << std::endl;
  return 0;
}
