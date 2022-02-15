#include <stdbool.h>
#include <string.h>

static bool inited = false;
static int map[256];

static void init() {
    memset(map, 0, 256 * sizeof(char));

    map[' '] = 0b00000000000000;
    map['0'] = 0b11000100100011;
    map['1'] = 0b00010000001000;
    map['2'] = 0b10000111100001;
    map['3'] = 0b10000111000011;
    map['4'] = 0b01000111000010;
    map['5'] = 0b11000011000011;
    map['6'] = 0b11000011100011;
    map['7'] = 0b10000100000010;
    map['8'] = 0b11000111100011;
    map['9'] = 0b11000111000011;
    map['A'] = 0b11000111100010;
    map['B'] = 0b10010101001011;
    map['C'] = 0b11000000100001;
    map['D'] = 0b10010100001011;
    map['E'] = 0b11000011100001;
    map['e'] = 0b00000010110001;
    map['F'] = 0b11000011100000;
    map['G'] = 0b11000001100011;
    map['H'] = 0b01000111100010;
    map['I'] = 0b10010000001001;
    map['J'] = 0b00000100000011;
    map['K'] = 0b01001010100100;
    map['L'] = 0b01000000100001;
    map['M'] = 0b01101100100010;
    map['N'] = 0b01100100100110;
    map['O'] = 0b11000100100011;
    map['P'] = 0b11000111100000;
    map['Q'] = 0b11000100100111;
    map['R'] = 0b11000111100100;
    map['S'] = 0b11000011000011;
    map['T'] = 0b10010000001000;
    map['U'] = 0b01000100100011;
    map['V'] = 0b01001000110000;
    map['W'] = 0b01000100110110;
    map['X'] = 0b00101000010100;
    map['Y'] = 0b00101000001000;
    map['Z'] = 0b10001000010001;
    map['_'] = 0b00000000000001;
    map['-'] = 0b00000011000000;
    map['/'] = 0b00001000010000;
    map['*'] = 0b00111011011100;
    map['+'] = 0b00010011001000;
    map['%'] = 0b01101011010110;
    map['?'] = 0b10000101001000;
    ///map['>'] = 0b00100000010000;
    map['<'] = 0b00001000000100;
    map['['] = 0b11000000100001;
    map[']'] = 0b10000100000011;
    map['='] = 0b00000011000001;
    map['}'] = 0b00100011010000;
    //map['^'] = 0b00000000010101;
    ///map['v'] = 0b10101000000000;
    
    map['('] = 0b00001000000100;
    map[')'] = 0b00100000010000;
    map['!'] = 0b00000011000010;
    map['^'] = 0b10001100010000;
    map['v'] = 0b00000110000110;
    map['>'] = 0b00100010000001;
    map[';'] = 0b01100000110000;
    map['|'] = 0b00010000001000;
    map['*'] = 0b00111011011100;
}

int get_led_segments(char c) {
    if (!inited) { init(); }
    return map[c];
}