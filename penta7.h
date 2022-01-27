#ifndef PENTA7_H
#define PENTA7_H

#include "ti57.h"

/******************************************************************************
 *
 * API for clients that want to implement a Penta7 emulator, a calculator built
 * on top of the TI-57.
 *
 * The goal of Penta7 is to maintain backwards compatibility with the TI-57
 * while being enjoyable to use today:
 * - programs are easier to read with its alphanumeric display
 * - computations are easier to follow with the display showing the AOS stack
 * - it is much faster than the TI-57
 *
 ******************************************************************************/

/**
 * The different speeds of the calculator that dictate at what rate
 * 'penta7_advance' should be called.
 * - PENTA7_IDLE: no need to call 'penta7_advance' until the next key press or
 *   key release.
 * - PENTA7_SLOW: at a rate of around 5000 times a second. This simulates the
 *   speed of an actual TI-57.
 * - PENTA7_FAST: at an as fast rate as possible.
 */
typedef enum penta7_speed_e {
    PENTA7_IDLE,
    PENTA7_SLOW,
    PENTA7_FAST,
} penta7_speed_t;

typedef struct penta7_s {
    ti57_t ti57;
} penta7_t;

/** Initializes a Penta7. */
void penta7_init(penta7_t *penta7);

/**
 * Should be called at the rate indicated by penta7_speed_t, initially at
 * PENTA7_FAST speed.
 */
penta7_speed_t penta7_advance(penta7_t *penta7);

/** Should be called when a key is pressed (row in 0..7, col in 0..4). */
penta7_speed_t penta7_key_press(penta7_t *penta7, int row, int col);

/** Should be called when a key is released. */
penta7_speed_t penta7_key_release(penta7_t *penta7);

/**
 * The display as a string.
 *
 * The display is composed of 12 LEDs and each one is represented by 1
 * character (or 2 characters if there is an additional dot).
 *
 * Characters:
 * - legacy from TI-57: 'blank character' 0..9 A b C d E
 * - additional common characters: B D F..Z ( ) + - / .
 * - multiply: x (different from X)
 * - square root: v
 * - up arrow: ^ (for exponentiation)
 * - inverse: !
 * For example: "   02   vX  ".
 */
char *penta7_get_display(penta7_t *penta7);

#endif  /* !PENTA7_H */
