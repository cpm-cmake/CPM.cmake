#include <xxh3.h>

#include <iostream>

int main() {
  std::string example = "Hello World!";
  XXH64_hash_t hash = XXH3_64bits(example.data(), example.size());

  std::cout << "Hash: " << hash << std::endl;

  return 0;
}
