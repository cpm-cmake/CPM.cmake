#include <lars/parser/extension.h>
#include <glue/lua.h>
#include <stdexcept>
#include <iostream>

int main() {
  auto lua = glue::LuaState();
  lua.openStandardLibs();

  lua["parser"] = lars::glue::parser();
  
  lua.run(R"(
    wordParser = parser.Program.create()

    wordParser:setRule("Whitespace", "[ \t]")
    wordParser:setSeparatorRule("Whitespace")

    wordParser:setRule("Word", "[a-zA-Z]+")
    
    wordParser:setRuleWithCallback("Words", "Word*", function(e) 
      local N = e:size()
      local res = {}
      for i=0,N-1 do res[#res+1] = e:get(i):string() end
      return res
    end)

    wordParser:setStartRule("Words")
  )");

  lua.run(R"(
    while true do
      print("please enter some words or 'quit' to exit");
      local input = io.read();
      if input == "quit" then os.exit() end
      local result
      ok, err = pcall(function() result = wordParser:run(input) end)
      if ok then
        print("you entered " .. #result .. " words!")
      else 
        print("error: " .. tostring(err))
      end
    end
  )");

  return 0;
}
