#define CATCH_CONFIG_MAIN

#include <cereal/archives/json.hpp>
#include <cereal/cereal.hpp>
#include <sstream>
#include <string>

struct player_data {
  int id{-1};
  std::string name{};
};

template <typename Archive> void serialize(Archive &archive, player_data const &data) {
  archive(cereal::make_nvp("id", data.id), cereal::make_nvp("name", data.name));
}

int main(int argc, char const *argv[]) {
  player_data player{3, "Gamer One"};
  std::ostringstream oss;
  cereal::JSONOutputArchive output(oss);
  output(cereal::make_nvp("player_data", player));

  std::cout << oss.str() << std::endl;

  return 0;
}
