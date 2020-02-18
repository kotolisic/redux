#include "SDL.h"
#include <stdlib.h>
#include <stdio.h>

class Gigatron {

protected:

    int width, height;

    SDL_Event    event;
    SDL_Surface* sdl_screen;

    unsigned short rom[65536]; // 64k x 16
    unsigned char  ram[32768]; // 32k x 8

    unsigned short pc, nextpc;
    unsigned char  ac, x, y, out, outx, inReg;

public:

    Gigatron(int, int, const char*);

    void start();
    void reset();
    void procstart();
    void tick();
};
