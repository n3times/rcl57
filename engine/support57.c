#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "ti57.h"
#include "state57.h"
#include "support57.h"

static char *DIGIT_KEYS[]  = {
    "0", "1", "2", "3", "4", "5", "6", "7",
    "8", "9", "A", "B", "C", "D", "E", "F",
};

static char *PRIMARY_KEYS[] = {
    "2ND", "INV", "LNX",  "CE", "CLR",
    "LRN", "X/T", "X^2",  "vX", "1/X",
    "SST", "STO", "RCL", "SUM", "Y^X",
    "BST",  "EE",   "(",   ")",   "/",
    "GTO",     0,     0,     0,   "x",
    "SBR",     0,     0,     0,   "-",
    "RST",     0,     0,     0,   "+",
    "R/S",     0,   ".", "+/-",   "=",
};

static char *SECONDARY_KEYS[] = {
    "2N2", "IN2", "LOG",  "CT", "CL2",
    "DMS", "P/R", "SIN", "COS", "TAN",
    "PSE", "INS", "EXC", "PRD",  "PI",
    "NOP", "DEL", "FIX", "INT", "|X|",
    "DSZ",     0,     0,     0, "DEG",
    "X=T",     0,     0,     0, "RAD",
    "X>T",     0,     0,     0, "GRD",
    "LBL",     0,  "s+",   "@",  "g2",
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

char *ti57_reg_to_str(ti57_reg_t reg)
{
    static char str[17];
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[reg[15 - i]];
    str[16] = 0;
    return str;
}

char *ti57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix)
{
    static char str[25];
    ti57_t ti57;
    ti57_reg_t *T;

    ti57_init(&ti57);
    while (ti57_get_activity(&ti57) == TI57_BUSY) {
        ti57_next(&ti57);
    }

    T = ti57_get_regT(&ti57);
    for (int i = 0; i <= 13; i++)
        (*T)[i] = (*reg)[i];
    ti57.X[4][14] = 9 - fix;
    if (sci)
        ti57.B[15] = 0x8;

    ti57_key_press(&ti57, 1, 1);
    while (ti57_get_activity(&ti57) == TI57_BUSY) {
        ti57_next(&ti57);
    }
    ti57_key_release(&ti57);
    while (ti57_get_activity(&ti57) == TI57_BUSY) {
        ti57_next(&ti57);
    }
    strcpy(str, ti57_trim(ti57_get_display(&ti57)));
    char *last = str + strlen(str) - 1;
    if (*last == '.')
        *last = 0;
    return str;
}
