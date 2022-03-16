#include "key57.h"

#include <assert.h>

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
    "DMS", "P~R", "SIN", "COS", "TAN",
    "PAU", "INS", "EXC", "PRD",  "PI",
    "NOP", "DEL", "FIX", "INT", "|X|",
    "DSZ",     0,     0,     0, "DEG",
    "X=T",     0,     0,     0, "RAD",
    "X>T",     0,     0,     0, "GRD",
    "LBL",     0,  "s+",   "@", "g^2",
};

static char *UNICODE_PRIMARY_KEYS[] = {
    "2nd",     "INV",       "lnx",        "CE",     "CLR",
    "LRN",     "x:t",   "x\u00b2",   "\u221ax",     "1/x",
    "SST",     "STO",       "RCL",       "SUM", "y\u02e3",
    "BST",      "EE",         "(",         ")",  "\u00f7",
    "GTO",         0,           0,           0,  "\uff58",
    "SBR",         0,           0,           0,  "\uff0d",
    "RST",         0,           0,           0,  "\uff0b",
    "R/S",         0,         ".",       "+/-",  "\uff1d",
};

static char *UNICODE_SECONDARY_KEYS[] = {
    "2n2",       "IN2",     "log",     "C.t",          "CLR",
    "D.MS", "P\u2192R",     "sin",     "cos",          "tan",
    "Pause",     "Ins",     "Exc",     "Prd",       "\u03c0",
    "Nop",       "Del",     "Fix",     "Int",          "|x|",
    "Dsz",           0,         0,         0,          "Deg",
    "x=t",           0,         0,         0,          "Rad",
    "x\u2265t",      0,         0,         0,         "Grad",
    "Lbl",           0, "\u03A3+", "x\u0305", "\u03C3\u00b2",
};

static char *get_name(key57_t key, bool unicode)
{
    int row, col;
    bool sec;

    if (key < 0x10) return DIGIT_KEYS[key];

    char **primary_keys = unicode ? UNICODE_PRIMARY_KEYS : PRIMARY_KEYS;
    char **secondary_keys = unicode ? UNICODE_SECONDARY_KEYS : SECONDARY_KEYS;

    row = ((key & 0xf0) >> 4) - 1;
    col = (key & 0x0f) - 1;
    sec = (key & 0x0f) >= 6;
    return sec ? secondary_keys[row * 5 + col - 5]
               : primary_keys[row * 5 + col];
}

key57_t key57_get_key(int row, int col, bool is_secondary)
{
    if (row == 0 && col == 0) return KEY57_NONE;

    assert(1 <= row && row <= 8);
    assert(1 <= col && col <= 5);

    key57_t key = (row << 4) | col;

    switch(key) {
    // Digits:
    case 0x52: return 0x07;
    case 0x53: return 0x08;
    case 0x54: return 0x09;
    case 0x62: return 0x04;
    case 0x63: return 0x05;
    case 0x64: return 0x06;
    case 0x72: return 0x01;
    case 0x73: return 0x02;
    case 0x74: return 0x03;
    case 0x82: return 0x00;

    default: return is_secondary ? key + 5 : key;
    }
}

char *key57_get_ascii_name(key57_t key)
{
    return get_name(key, false);
}

char *key57_get_unicode_name(key57_t key)
{
    return get_name(key, true);
}
