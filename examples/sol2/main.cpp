#include <cassert>
#include <sol/sol.hpp>

struct vars {
  int boop = 0;
};

int main() {
  sol::state lua;
  lua.open_libraries(sol::lib::base);
  lua.new_usertype<vars>("vars", "boop", &vars::boop);
  lua.script(
      "beep = vars.new()\n"
      "beep.boop = 1\n"
      "print('beep boop')");
  assert(lua.get<vars>("beep").boop == 1);
}