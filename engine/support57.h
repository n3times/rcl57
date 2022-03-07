#ifndef support57_h
#define support57_h

#include "rom57.h"
#include "state57.h"

/**
 * Support API.
 */

/** Name of a given key. For example: 0x34 -> "SUM". */
char *support57_get_keyname(ti57_key_t key);

/** Unicode name of a given key. */
char *support57_get_keyname_unicode(ti57_key_t key);

/** Trims 'str'. */
char *support57_trim(char *str);

/**
 * A raw string representation of a given internal register. Characters in
 * '0'-'F'.
 */
char *support57_reg_to_str(ti57_reg_t reg);

/**
 * A string representation of the user register at 'reg'. For example:
 * "-1.23 45".
 *
 * Note that digits of reg at 14 and 15, as well as the two higher bits at 13,
 * are ignored.
 */
char *support57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix);

void burst_until_idle(ti57_t *ti57);

void burst_until_busy(ti57_t *ti57);

#endif  /* !support57_h */
