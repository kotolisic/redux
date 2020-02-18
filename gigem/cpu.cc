#include "gigatron.h"

#include <cstdlib>
#include <ctime>

// Первый старт
void Gigatron::procstart() {

    reset();
    srand( static_cast<unsigned int> (time(0)) );
    for (int i = 0; i < 32768; i++) {
        ram[i] = rand() % 256;
    }
}

// Сброс процессора
void Gigatron::reset() {

    pc      = 0;
    nextpc  = (pc + 1) & 0xFFFF;
    ac      = 0;
    x       = 0;
    y       = 0;
    out     = 0;
    outx    = 0;
    inReg   = 0xff; // active low!
}

// Один такт процессора -- одна инструкция
void Gigatron::tick() {

    uint16_t let_pc = pc;

    pc     = nextpc;
    nextpc = (nextpc + 1) & 0xFFFF;

    uint16_t ir   = rom[ let_pc ];
    uint8_t  op   = (ir >> 13) & 0x0007;
    uint8_t  mode = (ir >> 10) & 0x0007;
    uint8_t  bus  = (ir >> 8) & 0x0003;
    uint8_t  d    = (ir >> 0) & 0x00ff;

    switch (op) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            // this.aluOp(op, mode, bus, d);
            break;
        case 6:
            // this.storeOp(mode, bus, d);
            break;
        case 7:
            // this.branchOp(mode, bus, d);
            break;
    }
}
