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
typedef unsigned char ti57_key_t;

/** Name of a given key. For example: 0x34 -> "SUM". */
char *support57_get_keyname(ti57_key_t key);

/** Unicode name of a given key. */
char *support57_get_keyname_unicode(ti57_key_t key);

#endif /* key57_h */
