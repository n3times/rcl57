#include "cpu57.h"
#include "state57.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>


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


char *get_keyname(key_t key)
{
    int row, col;
    bool_t sec;

    if (key < 0x10) return DIGIT_KEYS[key];

    row = ((key & 0xf0) >> 4) - 1;
    col = (key & 0x0f) - 1;
    sec = (key & 0x0f) >= 6;
    return sec ? SECONDARY_KEYS[row * 5 + col - 5]
               : PRIMARY_KEYS[row * 5 + col];
}

char *trim(char *str)
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

char *reg_to_str(reg_t reg, char *str)
{
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[reg[15 - i]];
    str[16] = 0;
    return str;
}

char *user_reg_to_str(reg_t *reg, char *str, opcode_t *ROM)
{
    state_t s;
    reg_t *T;

    init(&s);
    burst(&s, 200, ROM);

    T = get_regT(&s);
    for (int i = 0; i <= 13; i++)
        (*T)[i] = (*reg)[i];

    key_press(&s, 1, 1);
    burst(&s, 400, ROM);
    key_release(&s);
    burst(&s, 100, ROM);

    char display[25];
    get_display(&s, display);
    strcpy(str, trim(display));
    char *last = str + strlen(str) - 1;
    if (*last == '.')
        *last = 0;
    return str;
}
