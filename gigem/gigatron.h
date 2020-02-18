#include "SDL.h"
#include <stdlib.h>
#include <stdio.h>

static const uint8_t ZERO = 0x80;
static const uint8_t VSYNC = 0x80;
static const uint8_t HSYNC = 0x40;
static const uint32_t SAMPLES_PER_SECOND = 44100;

// AudioBuffer
static int au_data_buffer[441*32];
static int au_sdl_frame;
static int au_cpu_frame;

enum Buttons {

    BUTTON_A        = 0x80,
    BUTTON_B        = 0x40,
    BUTTON_SELECT   = 0x20,
    BUTTON_START    = 0x10,
    BUTTON_UP       = 0x08,
    BUTTON_DOWN     = 0x04,
    BUTTON_LEFT     = 0x02,
    BUTTON_RIGHT    = 0x01
};


class Gigatron {

protected:

    int width, height;

    SDL_Event       event;
    SDL_Surface*    sdl_screen;
    SDL_AudioSpec   audio_device;

    // CPU
    uint16_t rom[65536]; // 64k x 16
    uint8_t  ram[65536]; // 64k x 8
    uint16_t pc, nextpc;
    uint16_t ramMask;
    uint8_t  ac, x, y, out, outx, inReg;

    // VGA
    int row, col,
        minRow, maxRow,
        minCol, maxCol,
        vga_out;

    // Audio
    int au_cycle, au_cpu_shift, au_sample_shift;


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

    // VGA
    void     vga_init();
    void     vga_tick();
    void     pset(int x, int y, uint32_t color);

    // Gamepad
    void     gamepad_press(SDL_Event event);
    void     gamepad_up(SDL_Event event);
    int      get_key(SDL_Event event);

    // Audio
    void    audio_init();
    void    audio_tick();
};
