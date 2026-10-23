#include <types.h>
extern uint8_t regs[4];
extern uint8_t ram[256];

void mov(uint8_t mode, uint8_t operand) {
    switch (mode) {
        case 0: regs[0] = operand; break;
        case 1: regs[0] = regs[operand]; break;
        case 2: regs[0] = ram[operand]; break;
        case 3: regs[0] = ram[regs[operand]]; break;
    }
}