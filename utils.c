#include <fb.h>
#include <keyboard.h>
#include <types.h>

char buffer[256];

char *input()
{
    unsigned char i = 0;
    char c = (char)keyboard_get_char();
    while (1) {
        c = (char)keyboard_get_char();
        if (c != 0) {
            buffer[i] = c;
            i++;
            if (c == '\n') {
                buffer[i] = '\0';
                break;
            } else if (c == '\b') {
                if (i > 0) {
                    i--;
                }
                buffer[i] = '\0';
            }
        }
    }
    return buffer;
}