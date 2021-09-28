// adapted from : https://gist.github.com/fschr/92958222e35a823e738bb181fe045274

#include <SDL.h>

#include <iostream>

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480

int main() {
  SDL_Window* window = NULL;
  SDL_Surface* screenSurface = NULL;

  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    std::cerr << "Could not initialize SDL2" << SDL_GetError() << std::endl;
    return 1;
  }
  window = SDL_CreateWindow("hello_sdl2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                            SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
  if (window == NULL) {
    std::cerr << "Could not create window" << SDL_GetError() << std::endl;
    return 1;
  }

  screenSurface = SDL_GetWindowSurface(window);
  SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0xFF, 0xFF));
  SDL_UpdateWindowSurface(window);
  SDL_Delay(2000);
  SDL_DestroyWindow(window);
  SDL_Quit();

  return 0;
}
