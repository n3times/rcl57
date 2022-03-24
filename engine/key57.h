/**
 * Describes the keys on the keyboard.
 */

#ifndef key57_h
#define key57_h

#include <stdbool.h>

#define KEY57_2ND  0x11
#define KEY57_INV  0x12
#define KEY57_CLR  0x15
#define KEY57_LRN  0x21
#define KEY57_SST  0x31
#define KEY57_INS  0x37
#define KEY57_BST  0x41
#define KEY57_DEL  0x47
#define KEY57_SBR  0x61
#define KEY57_RS   0x81

#define KEY57_NONE 0xFF

/** Represents one of the keys of the keyboard. */
typedef unsigned char key57_t;

/** Returns the primary or secondary key at a given row (1..8) and column (1..5). */
key57_t key57_get_key(int row, int col, bool is_secondary);

/**
 * Returns the ASCII name of a given key.
 *
 * A short simple name that can be printed easily, but
 * may not be very readable.
 *
 * For example: "SUM" or "@" (average).
 */
char *key57_get_ascii_name(key57_t key);

/**
 * Returns the unicode name of a given key.
 *
 * A readable accurate name that requires Unicode support.
 *
 * For example: "SUM" or "x\u0305" (average).
 */
char *key57_get_unicode_name(key57_t key);

#endif /* key57_h */
