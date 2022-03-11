#include <stdbool.h>
#include <string.h>

static int LEDS_MAP[256];

static void init() {
    memset(LEDS_MAP, 0, 256 * sizeof(int));

    LEDS_MAP[' '] = 0b00000000000000;

    // Digits.
    LEDS_MAP['0'] = 0b11000100100011;
    LEDS_MAP['1'] = 0b00000100000010;
    LEDS_MAP['2'] = 0b10000111100001;
    LEDS_MAP['3'] = 0b10000111000011;
    LEDS_MAP['4'] = 0b01000111000010;
    LEDS_MAP['5'] = 0b11000011000011;
    LEDS_MAP['6'] = 0b11000011100011;
    LEDS_MAP['7'] = 0b10000100000010;
    LEDS_MAP['8'] = 0b11000111100011;
    LEDS_MAP['9'] = 0b11000111000011;

    // Uppercase letters.
    LEDS_MAP['A'] = 0b11000111100010;
    LEDS_MAP['B'] = 0b10010101001011;
    LEDS_MAP['C'] = 0b11000000100001;
    LEDS_MAP['D'] = 0b10010100001011;
    LEDS_MAP['E'] = 0b11000011100001;
    LEDS_MAP['F'] = 0b11000011100000;
    LEDS_MAP['G'] = 0b11000001100011;
    LEDS_MAP['H'] = 0b01000111100010;
    LEDS_MAP['I'] = 0b00010000001000;
    LEDS_MAP['J'] = 0b00000100000011;
    LEDS_MAP['K'] = 0b01001010100100;
    LEDS_MAP['L'] = 0b01000000100001;
    LEDS_MAP['M'] = 0b01101100100010;
    LEDS_MAP['N'] = 0b01100100100110;
    LEDS_MAP['O'] = 0b11000100100011;
    LEDS_MAP['P'] = 0b11000111100000;
    LEDS_MAP['Q'] = 0b11000100100111;
    LEDS_MAP['R'] = 0b11000111100100;
    LEDS_MAP['S'] = 0b11000011000011;
    LEDS_MAP['T'] = 0b10010000001000;
    LEDS_MAP['U'] = 0b01000100100011;
    LEDS_MAP['V'] = 0b01001000110000;
    LEDS_MAP['W'] = 0b01000100110110;
    LEDS_MAP['X'] = 0b00101000010100;
    LEDS_MAP['Y'] = 0b00101000001000;
    LEDS_MAP['Z'] = 0b10001000010001;

    // Some lowercase letters.
    LEDS_MAP['e'] = 0b00000010110001;
    LEDS_MAP['n'] = 0b00000011100010;
    LEDS_MAP['r'] = 0b00000011100000;
    LEDS_MAP['t'] = 0b01000010100000;
    LEDS_MAP['x'] = 0b00101000010100;

    // Some symbols.
    LEDS_MAP['_'] = 0b00000000000001;
    LEDS_MAP['-'] = 0b00000011000000;
    LEDS_MAP['/'] = 0b00001000010000;
    LEDS_MAP['*'] = 0b00111011011100;
    LEDS_MAP['+'] = 0b00010011001000;
    LEDS_MAP['?'] = 0b10000101001000;
    LEDS_MAP['<'] = 0b00001000000100;
    LEDS_MAP['['] = 0b11000000100001;
    LEDS_MAP[']'] = 0b10000100000011;
    LEDS_MAP['='] = 0b00000011000001;
    LEDS_MAP['('] = 0b00001000000100;
    LEDS_MAP[')'] = 0b00100000010000;
    LEDS_MAP['|'] = 0b00010000001000;
    LEDS_MAP['!'] = 0b00000011000010;  // inv/negation symbol
    LEDS_MAP['^'] = 0b10001100010000;  // exponentiation
    LEDS_MAP['v'] = 0b00000110000110;  // square root
    LEDS_MAP['>'] = 0b00100010000001;  // >=
    LEDS_MAP['@'] = 0b10101000010100;  // average
    LEDS_MAP['s'] = 0b10100000010001;  // sigma
    LEDS_MAP['g'] = 0b00000011100101;  // variance
    LEDS_MAP['%'] = 0b01100011000110;  // exchange symbol between x and t
    LEDS_MAP['~'] = 0b00000011000000;  // "right arrow" for P->R
}

int leds57_get_segments(char c) {
    static bool initialized = false;

    if (!initialized) {
        init();
        initialized = true;
    }
    return LEDS_MAP[(int)c];
}
