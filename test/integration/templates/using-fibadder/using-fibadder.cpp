#include <fibadder/fibadder.hpp>
#include <cstdio>

int main() {
  int sum = fibadder::fibadd(6, 7);
  std::printf("%d\n", sum);
  return 0;
}
