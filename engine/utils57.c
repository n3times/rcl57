#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "ti57.h"
#include "state57.h"
#include "utils57.h"

char *utils57_trim(char *str)
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

char *utils57_reg_to_str(ti57_reg_t reg)
{
    static char str[17];
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[reg[15 - i]];
    str[16] = 0;
    return str;
}

char *utils57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix)
{
    // Hack: we run a new emulator to compute the string by modifying its state. We place reg in the
    // T register, set sci and fix and simulate a key press on "x:t", getting the sought result on
    // the display.

    static char str[25];
    ti57_t ti57;
    ti57_reg_t *T;

    ti57_init(&ti57);
    utils57_burst_until_idle(&ti57);

    T = ti57_get_regT(&ti57);
    for (int i = 0; i <= 13; i++)
        (*T)[i] = (*reg)[i];
    ti57.X[4][14] = 9 - fix;
    if (sci)
        ti57.B[15] = 0x8;

    ti57_key_press(&ti57, 2, 2);
    utils57_burst_until_idle(&ti57);
    ti57_key_release(&ti57);
    utils57_burst_until_idle(&ti57);
    strcpy(str, utils57_trim(ti57_get_display(&ti57)));
    char *last = str + strlen(str) - 1;
    if (*last == '.') {
        *last = 0;
    }
    return str;
}

void utils57_burst_until_idle(ti57_t *ti57)
{
    for ( ; ; ) {
        if (ti57->activity == TI57_POLL_PRESS ||
            ti57->activity == TI57_POLL_PRESS_BLINK) {
            if (!ti57->is_key_pressed) {
                break;
            }
        } else if (ti57->activity == TI57_POLL_RELEASE ||
                   ti57->activity == TI57_POLL_RS_RELEASE) {
            if (ti57->is_key_pressed) {
                break;
            }
        }
        ti57_next(ti57);
    }
}

void utils57_burst_until_busy(ti57_t *ti57)
{
    while (ti57->activity != TI57_BUSY) {
        ti57_next(ti57);
    }
}
