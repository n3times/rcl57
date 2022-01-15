#ifndef SUPPORT57_H
#define SUPPORT57_H

#include "state57.h"

/**
 * Support functions.
 */

/** Name of a given key. For example: 0x34 -> "SUM". */
char *get_keyname(key_t key);

/** Trims 'str'. */
char *trim(char *str);

/**
 * Returns a raw string representation of a given internal register. Characters
 * in '0'-'F'.
 *
 * 'str' must hold 17 characters at least.
 */
char *reg_to_str(reg_t reg, char *str);

/**
 * Returns a string representation of the user register at 'reg'. For example:
 * "-1.23 34".
 *
 * Note that digits of reg at 14 and 15, as well as the two higher bits at 13,
 * are ignored.
 * TODO: have the possibility of specifying sci and fix.
 */
char *user_reg_to_str(reg_t *reg, char *str, opcode_t *ROM);

#endif  /* !SUPPORT57_H */
