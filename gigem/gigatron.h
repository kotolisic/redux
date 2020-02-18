#include "SDL.h"
#include <stdlib.h>
#include <stdio.h>

static const uint8_t ZERO = 0x80;

class Gigatron {

protected:

    int width, height;

    SDL_Event    event;
    SDL_Surface* sdl_screen;

    uint16_t rom[65536]; // 64k x 16
    uint8_t  ram[32768]; // 32k x 8

    uint16_t pc, nextpc;
    uint16_t ramMask;
    uint8_t  ac, x, y, out, outx, inReg;

public:

    Gigatron(int, int, const char*);

    // Инициализация
    void    start();
    void    reset();
    void    procstart();

    // Исполнительное устройство
    void     tick();
    void     aluOp   (uint8_t op,   uint8_t mode, uint8_t bus, uint8_t d);
    void     storeOp (uint8_t mode, uint8_t bus,  uint8_t d);
    void     branchOp(uint8_t mode, uint8_t bus,  uint8_t d);
    uint16_t address (uint8_t mode, uint8_t d);
    uint16_t offset  (uint8_t bus,  uint8_t d);
};
