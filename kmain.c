#include <gdt.h>
#include <multiboot.h>
#include <idt.h>
#include <keyboard.h>
#include <fb.h>
#include <am8.h>
#include <types.h>

void kmain(unsigned int ebx) {
    extern uint8_t regs[4];
    gdt_install();
    idt_install();
    keyboard_init();
    __asm__ ("sti");
    multiboot_info_t *mbi = (multiboot_info_t *)ebx;
    module_t *modules = (module_t *)mbi->mods_addr;
    uint8_t *cmdline = (uint8_t *)mbi->cmdline;
    if (strncmp((const char *)cmdline, "a=", 2) == 0) {
        uint8_t a_value;
        cmdline += 2; // Move past "a="
        a_value = cmdline[0];
        a_value = str_to_int((const char *)&a_value);
        regs[0] = a_value;
        cmdline += 2;
        if (strncmp((const char *)cmdline, "b=", 2) == 0) {
            uint8_t b_value;
            cmdline += 2; // Move past "b="
            b_value = cmdline[0];
            b_value = str_to_int((const char *)&b_value);
            regs[1] = b_value;
            cmdline += 2;
            if (strncmp((const char *)cmdline, "c=", 2) == 0) {
                uint8_t c_value;
                cmdline += 2; // Move past "c="
                c_value = cmdline[0];
                c_value = str_to_int((const char *)&c_value);
                regs[2] = c_value;
                cmdline += 2;
                if (strncmp((const char *)cmdline, "d=", 2) == 0) {
                    uint8_t d_value;
                    cmdline += 2; // Move past "d="
                    d_value = cmdline[0];
                    d_value = str_to_int((const char *)&d_value);
                    regs[3] = d_value;
                    cmdline += 2;
                }
            }
        }
    }
    am8((char *)modules[0].mod_start);
}