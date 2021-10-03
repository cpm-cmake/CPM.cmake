#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>

int main() {
  sf::RenderWindow win(sf::VideoMode(800, 600), "SFML window");

  while (win.isOpen()) {
    sf::Event event;
    while (win.pollEvent(event)) {
      if (event.type == sf::Event::Closed) win.close();
    }
    win.clear(sf::Color::Black);
    win.display();
  }
  return 0;
}
