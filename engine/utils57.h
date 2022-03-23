/**
 * Util functions.
 */

#ifndef utils57_h
#define utils57_h

#include "ti57.h"

/** Trims 'str'. */
char *utils57_trim(char *str);

/** Returns a raw string representation of a given internal register. Characters in '0'..'F'. */
char *utils57_reg_to_str(ti57_reg_t reg);

/**
 * Returns a string representation of the user register at 'reg'. For example:
 * "-1.23 45".
 *
 * Note that digits of reg at indices 14 and 15, as well as the two higher bits
 * at index 13, are ignored.
 */
char *utils57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix);

/**
 * Given 2 registers, one representing the display digits (typically register A in ti57_t) and the other
 * one the mask (typically register ABin ti57_t),  returns a string representing the display.
 */
char *utils57_display_to_str(ti57_reg_t *digits, ti57_reg_t *mask);

/** Calls repeatedly 'ti57_next' until the calculator is waiting for a key press or a key release. */
void utils57_burst_until_idle(ti57_t *ti57);

/** Calls repeatedly 'ti57_next' until the calculator is in a busy state. */
void utils57_burst_until_busy(ti57_t *ti57);

#endif  /* !utils57_h */
