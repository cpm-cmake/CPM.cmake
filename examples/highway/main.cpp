#include <hwy/contrib/sort/vqsort.h>  // hwy::VQSort() for large data sets

#include <cstdint>
#include <random>
#include <vector>

// Use hwy::VQSort to sort larger vectors
inline void sort_large(std::vector<double>& v) {
  hwy::VQSort(v.data(), v.size(), hwy::SortAscending{});
}

int main(int, char**) {
  std::random_device random_device;
  std::default_random_engine random_engine(random_device());
  std::uniform_real_distribution<double> uniform_dist(0.0, 100.0);

  const std::size_t sz = 100000;
  std::vector<double> v;
  v.reserve(sz);
  for (std::size_t i = 0; i < sz; ++i) {
    v.push_back(uniform_dist(random_engine));
  }

  sort_large(v);

  return 0;
}
