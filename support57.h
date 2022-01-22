#ifndef SUPPORT57_H
#define SUPPORT57_H

#include "state57.h"

/**
 * Support API.
 */

/**
 * The different activity levels of the calculator:
 * - TI57_IDLE: the display is static and the calculator is waiting for user
 *   input. The client can safely stop running the emulator until the next key
 *   press or key release.
 * - TI57_SLOW: the calculator is not IDLE and is showing some information on
 *   the display: pausing, tracing, or the display blinking. The client should
 *   run the emulator at a speed close to the original one.
 * - TI57_FAST: the calculator is fully busy and computing as fast as possible.
 *   The client may run the emulator faster than the actual calculator without
 *   the user losing any meaningful information.
 */
typedef enum ti57_speed_e {
    TI57_IDLE,
    TI57_SLOW,
    TI57_FAST,
} ti57_speed_t;

/** Name of a given key. For example: 0x34 -> "SUM". */
char *ti57_get_keyname(ti57_key_t key);

/** Trims 'str'. */
char *ti57_trim(char *str);

/**
 * A raw string representation of a given internal register. Characters in
 * '0'-'F'.
 *
 * 'str' must hold 17 characters at least.
 */
char *ti57_reg_to_str(ti57_reg_t reg, char *str);

/**
 * A string representation of the user register at 'reg'. For example:
 * "-1.23 45".
 *
 * Note that digits of reg at 14 and 15, as well as the two higher bits at 13,
 * are ignored.
 */
char *ti57_user_reg_to_str(ti57_reg_t *reg, bool sci, int fix, char *str,
                           ti57_opcode_t *ROM);

/** The current speed of the calculator. */
ti57_speed_t ti57_get_speed(ti57_state_t *s);

#endif  /* !SUPPORT57_H */
