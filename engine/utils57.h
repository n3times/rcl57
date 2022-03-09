#ifndef utils57_h
#define utils57_h

#include "key57.h"
#include "rom57.h"
#include "state57.h"

/**
 * Util functions.
 */

/** Trims 'str'. */
char *utils57_trim(char *str);

/**
 * A raw string representation of a given internal register. Characters in
 * '0'-'F'.
 */
char *utils57_reg_to_str(ti57_reg_t reg);

/**
 * A string representation of the user register at 'reg'. For example:
 * "-1.23 45".
 *
 * Note that digits of reg at 14 and 15, as well as the two higher bits at 13,
 * are ignored.
 */
char *utils57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix);

void utils57_burst_until_idle(ti57_t *ti57);

void utils57_burst_until_busy(ti57_t *ti57);

#endif  /* !utils57_h */
