#include <benchmark/benchmark.h>
#include <vector>
#include <algorithm>
#include <random>

#include <fibonacci.h>


std::vector<unsigned> createTestNumbers(){
  std::vector<unsigned> v;
  for (int i=0;i<25;++i) v.emplace_back(i);
  std::random_device rd;
  std::mt19937 g(rd());
  std::shuffle(v.begin(), v.end(), g);
  return v;
}

void fibonacci(benchmark::State& state) {
  auto numbers = createTestNumbers();
  for (auto _ : state) {
    for (auto v: numbers) benchmark::DoNotOptimize(fibonacci(v));
  }
}

BENCHMARK(fibonacci);

void fastFibonacci(benchmark::State& state) {
  auto numbers = createTestNumbers();
  for (auto _ : state) {
    for (auto v: numbers) benchmark::DoNotOptimize(fastFibonacci(v));
  }
}

BENCHMARK(fastFibonacci);

BENCHMARK_MAIN();
