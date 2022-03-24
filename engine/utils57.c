#include "utils57.h"

#include <string.h>

char *utils57_trim(char *str)
{
    char *begin, *end;

    begin = str;
    while (*begin == ' ') {
        begin++;
    }
    end = begin + strlen(begin) - 1;
    while (*end == ' ') {
        end--;
    }
    *(end + 1) = 0;
    memmove(str, begin, strlen(begin) + 1);
    return str;
}

char *utils57_reg_to_str(ti57_reg_t reg)
{
    static char str[17];
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++) {
        str[i] = digits[reg[15 - i]];
    }
    str[16] = 0;
    return str;
}

char *utils57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix)
{
    // Hack: we run a new emulator and modify its state to compute the string representation of reg.

    static char str[25];
    ti57_t ti57;
    ti57_reg_t *T;

    // Initialize the emulator.
    ti57_init(&ti57);
    utils57_burst_until_idle(&ti57);

    // Place reg in register T.
    T = ti57_get_regT(&ti57);
    memcpy(T, reg, sizeof(ti57_reg_t));

    // Set sci and fix.
    ti57.X[4][14] = 9 - fix;
    if (sci) {
        ti57.B[15] = 0x8;
    }

    // Press x:t key
    ti57_key_press(&ti57, 2, 2);
    utils57_burst_until_idle(&ti57);
    ti57_key_release(&ti57);
    utils57_burst_until_idle(&ti57);

    // Retrieve result from display.
    strcpy(str, utils57_trim(utils57_display_to_str(&ti57.dA, &ti57.dB)));
    char *last = str + strlen(str) - 1;
    if (*last == '.') {
        *last = 0;
    }

    return str;
}

char *utils57_display_to_str(ti57_reg_t *digits, ti57_reg_t *mask)
{
    static char DIGITS[] = "0123456789AbCdEF";
    static char str[25];
    int k = 0;

    // Go through the 12 digits.
    for (int i = 11; i >= 0; i--) {
        // Compute the actual character based on the digit and the mask information
        char c;
        if ((*mask)[i] & 0x8) {
            c = ' ';
        } else if ((*mask)[i] & 0x1) {
            c = '-';
        } else {
            c = DIGITS[(*digits)[i]];
        }

        // Add character to the string.
        str[k++] = c;

        // Add the decimal point if necessary.
        if ((*mask)[i] & 0x2) {
            str[k++] = '.';
        }
    }
    str[k] = 0;

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
