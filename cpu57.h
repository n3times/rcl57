#ifndef CPU57_H
#define CPU57_H

#include "state57.h"

/**
 * API for clients that want to implement a TI-57 emulator.
 */

/** Initializes the state of a TI-57. */
void ti57_init(ti57_state_t *s);

/**
 * Executes the instruction at the current program counter address.
 *
 * An actual TI-57 is always executing instructions, possibly just polling for
 * user input. It takes around 1/5000 seconds to execute most instructions.
 *
 * Returns the relative cost of the instruction, most often 1 though some other
 * instructions, such as those involving the display, may take much longer.
 */
int ti57_next(ti57_state_t *s);

/**
 * Should be called when a key is pressed (row in 0..7, col in 0..4).
 */
void ti57_key_press(ti57_state_t *s, int row, int col);

/** Should be called when a key is released. */
void ti57_key_release(ti57_state_t *s);

/**
 * The display as a string.
 *
 * The display is composed of 12 LEDs and each one is represented by 1
 * character, or 2 characters if there is an additional dot.
 *
 * 'str' must be at least 25 characters long.
 */
char *ti57_get_display(ti57_state_t *s, char *str);

#endif  /* !CPU57_H */
