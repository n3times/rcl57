#ifndef key57_h
#define key57_h

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

/** Name of a given key. For example: 0x34 -> "SUM". */
char *key57_get_name(key57_t key);

/** Unicode name of a given key. */
char *key57_get_name_unicode(key57_t key);

#endif /* key57_h */
