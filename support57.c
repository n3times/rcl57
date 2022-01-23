#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "cpu57.h"
#include "state57.h"
#include "support57.h"

static char *DIGIT_KEYS[]  = {
    "0", "1", "2", "3", "4", "5", "6", "7",
    "8", "9", "A", "B", "C", "D", "E", "F",
};

static char *PRIMARY_KEYS[] = {
    "2ND", "INV", "LNX",  "CE", "CLR",
    "LRN", "X/T", "X^2",  "VX", "1/X",
    "SST", "STO", "RCL", "SUM", "Y^X",
    "BST",  "EE",   "(",   ")",   "/",
    "GTO",     0,     0,     0,   "X",
    "SBR",     0,     0,     0,   "-",
    "RST",     0,     0,     0,   "+",
    "R/S",     0,   ".", "+/-",   "=",
};

static char *SECONDARY_KEYS[] = {
    "2N2", "IN2", "LOG",  "CT", "CL2",
    "DMS", "P/R", "SIN", "COS", "TAN",
    "PSE", "INS", "EXC", "PRD",  "PI",
    "NOP", "DEL", "FIX", "INT", "ABS",
    "DSZ",     0,     0,     0, "DEG",
    "X=T",     0,     0,     0, "RAD",
    "X>T",     0,     0,     0, "GRD",
    "LBL",     0, "SIG", "AVG", "VAR",
};

char *ti57_get_keyname(ti57_key_t key)
{
    int row, col;
    bool sec;

    if (key < 0x10) return DIGIT_KEYS[key];

    row = ((key & 0xf0) >> 4) - 1;
    col = (key & 0x0f) - 1;
    sec = (key & 0x0f) >= 6;
    return sec ? SECONDARY_KEYS[row * 5 + col - 5]
               : PRIMARY_KEYS[row * 5 + col];
}

char *ti57_trim(char *str)
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

char *ti57_reg_to_str(ti57_reg_t reg, char *str)
{
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[reg[15 - i]];
    str[16] = 0;
    return str;
}

char *ti57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix, char *str)
{
    ti57_state_t s;
    ti57_reg_t *T;

    ti57_init(&s);
    while (ti57_get_activity(&s) == TI57_BUSY) {
        ti57_next(&s);
    }

    T = ti57_get_regT(&s);
    for (int i = 0; i <= 13; i++)
        (*T)[i] = (*reg)[i];
    s.X[4][14] = 9 - fix;
    if (sci)
        s.B[15] = 0x8;

    ti57_key_press(&s, 1, 1);
    while (ti57_get_activity(&s) == TI57_BUSY) {
        ti57_next(&s);
    }
    ti57_key_release(&s);
    while (ti57_get_activity(&s) == TI57_BUSY) {
        ti57_next(&s);
    }
    char display[25];
    ti57_get_display(&s, display);
    strcpy(str, ti57_trim(display));
    char *last = str + strlen(str) - 1;
    if (*last == '.')
        *last = 0;
    return str;
}

ti57_speed_t ti57_get_speed(ti57_state_t *s)
{
    ti57_activity_t activity = ti57_get_activity(s);

    switch(ti57_get_mode(s)) {
    case TI57_EVAL:
    case TI57_LRN:
        switch (activity) {
        case TI57_POLL:
            return TI57_IDLE;
        case TI57_BLINK:
            return TI57_SLOW;
        default:
            return TI57_FAST;
        }
    case TI57_RUN:
        if (ti57_is_stopping(s))
            // This solves an issue with the original TI-57 where stopping
            // execution on 'Pause' takes up to 1 second in RUN mode.
            return TI57_FAST;
        else if (ti57_is_trace(s) || activity == TI57_PAUSE)
            return TI57_SLOW;
        return TI57_FAST;
    }
}
