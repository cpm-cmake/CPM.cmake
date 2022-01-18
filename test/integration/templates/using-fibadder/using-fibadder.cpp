#include <cstdio>
#include <fibadder/fibadder.hpp>

int main() {
  int sum = fibadder::fibadd(6, 7);
  std::printf("%d\n", sum);
  return 0;
}
