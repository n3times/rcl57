/**
 * Describes keys on the keyboard, how they are encoded and their names.
 */

#ifndef key57_h
#define key57_h

#define KEY57_2ND  0x11
#define KEY57_INV  0x12
#define KEY57_CLR  0x15
#define KEY57_LRN  0x21
#define KEY57_SST  0x31
#define KEY57_STO  0x32
#define KEY57_BST  0x41
#define KEY57_EE   0x42
#define KEY57_SBR  0x61
#define KEY57_RS   0x81

#define KEY57_NONE 0xFF

/**
 * Encodes one of the keys of the keyboard.
 *
 * Digit keys are encoded as 0x0d. Other keys are encoded by their location
 * (row, col) on the keyboard:
 * - most significant 4 bits: row in 1..8
 * - least significant 4 bits: column in 1..5 for primary keys and in 6..A for
 *   secondary keys
 */
typedef unsigned char key57_t;

/** Returns the key at a given row (1..8) and col (1..5) */
key57_t key57_get_key(int row, int col);

/**
 * Returns the ascii name of a given key.
 *
 * A short simple name that can be printed easily, but
 * may not be very readable.
 *
 * For example: 0x34 -> "SUM", 0x89 -> "@" for average.
 */
char *key57_get_ascii_name(key57_t key);

/**
 * Returns the unicode name of a given key.
 *
 * A readable accurate name that requires Unicode support.
 *
 * For example: 0x34 -> "SUM", 0x89 -> "x\u0305" (average symbol).
 */
char *key57_get_unicode_name(key57_t key);

#endif /* key57_h */
