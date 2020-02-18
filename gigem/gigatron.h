#include "SDL.h"
#include <stdlib.h>
#include <stdio.h>

class Gigatron {
    
protected:
    
    int width, height;

    SDL_Event    event;
    SDL_Surface* sdl_screen;

public:

    Gigatron(int, int, const char*);
    
    void start();
};
