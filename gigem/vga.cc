#include "gigatron.h"

/**
 * horizontal:
 * {
 *      frontPorch: 16,
 *      pulse: 96,
 *      backPorch: 48,
 *      visible: 640,
 * },
 * vertical:
 * {
 *      frontPorch: 6,
 *      pulse: 8,
 *      backPorch: 27,
 *      visible: 480,
 * },
 **/

void Gigatron::vga_init() {

    row = 0;
    col = 0;
    
    minRow = 27 + 8;
    maxRow = minRow + 480;

    minCol = 48 + 96;
    maxCol = minCol + 640;

    vga_out = 0;
}

void Gigatron::vga_tick() {

    uint8_t let_out = out; // cpu.out
    uint8_t falling = vga_out & ~let_out; // vga.out 

    // After 4 more CPU cycles HSYNC increments row to 0
    if (falling & VSYNC) {
        row   = -1; 
    }

    if (falling & HSYNC) {
        col = 0;
        row++;
    }

    vga_out = out;

    if ((row >= minRow && row < maxRow) &&
        (col >= minCol && col < maxCol)) {
    
        uint8_t let_r = (let_out     ) & 3;
        uint8_t let_g = (let_out >> 2) & 3;
        uint8_t let_b = (let_out >> 4) & 3;

        for (int i = 0; i < 4; i++) { 
            pset((col - minCol) + i, (row - minRow), (85*let_r)*65536 + (85*let_g)*256 + (85*let_b));
        }

    }

    col += 4;
}