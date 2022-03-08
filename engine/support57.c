#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "ti57.h"
#include "state57.h"
#include "support57.h"

char *support57_trim(char *str)
{
    char *begin, *end;

    begin = str;
    while (*begin == ' ')
        begin++;
    end = begin + strlen(begin) - 1;
    while (*end == ' ')
        end--;
    *(end + 1) = 0;
    memmove(str, begin, strlen(begin) + 1);
    return str;
}

char *support57_reg_to_str(ti57_reg_t reg)
{
    static char str[17];
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[reg[15 - i]];
    str[16] = 0;
    return str;
}

char *support57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix)
{
    // Hack: we run a new emulator to compute the string by modifying its state. We place reg in the
    // T register, set sci and fix and simulate a key press on "x:t", getting the sought result on
    // the display.

    static char str[25];
    ti57_t ti57;
    ti57_reg_t *T;

    ti57_init(&ti57);
    burst_until_idle(&ti57);

    T = ti57_get_regT(&ti57);
    for (int i = 0; i <= 13; i++)
        (*T)[i] = (*reg)[i];
    ti57.X[4][14] = 9 - fix;
    if (sci)
        ti57.B[15] = 0x8;

    ti57_key_press(&ti57, 1, 1);
    burst_until_idle(&ti57);
    ti57_key_release(&ti57);
    burst_until_idle(&ti57);
    strcpy(str, support57_trim(ti57_get_display(&ti57)));
    char *last = str + strlen(str) - 1;
    if (*last == '.')
        *last = 0;
    return str;
}

void burst_until_idle(ti57_t *ti57)
{
   for ( ; ; ) {
        if (ti57->activity == TI57_POLL_KEY_PRESS ||
            ti57->activity == TI57_POLL_KEY_RUN_RELEASE ||
            ti57->activity == TI57_POLL_KEY_RELEASE ||
            ti57->activity == TI57_BLINK) {
            // Call 'next' a few more times to make sure the display gets updated.
            for (int i = 0; i < 20; i++) {
                ti57_next(ti57);
            }
            return;
        }
        ti57_next(ti57);
   }
}

void burst_until_busy(ti57_t *ti57)
{
    while (ti57->activity != TI57_BUSY) {
        ti57_next(ti57);
    }
}
