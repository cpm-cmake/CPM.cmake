#include <yaml-cpp/yaml.h>

#include <iostream>

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cout << "usage: " << argv[0] << " <path to yaml file>" << std::endl;
    return 1;
  }

  YAML::Node config = YAML::LoadFile(argv[1]);
  std::cout << "Parsed YAML:\n" << config << std::endl;

  return 0;
}
