#ifndef PENTA7_H
#define PENTA7_H

#include "ti57.h"

/******************************************************************************
 *
 * API for clients that want to implement a Penta7 emulator, a calculator built
 * on top of the TI-57.
 *
 * The goal of Penta7 is to maintain backward compatibility with the TI-57 while
 * being enjoyable to use today. Notably, programs are easier to read and write
 * with its alphanumeric display.
 *
 * For a faithful emulation, use ti57.h instead.
 *
 * Sample implementation:
 *   Init:
 *     penta7_t penta7;
 *     penta7_init(&penta7);
 *   On a timer, every 50ms:
 *     penta7_advance(penta7, 20, 100);
 *     // 'update_display' should be defined by the client.
 *     update_display(penta7_get_display(&penta7))
 *   On key press:
 *     penta7_key_press(&penta7, row, col);
 *   On key release:
 *     penta7_key_release(&penta7);
 *
 ******************************************************************************/

typedef struct penta7_s {
    ti57_t ti57;
    bool at_end_program;
} penta7_t;

/** Initializes a Penta7. */
void penta7_init(penta7_t *penta7);

/**
 * Runs the emulator for 'ms' milliseconds at a given speed.
 *
 * Set 'speedup' to 1 to get the speed of an actual TI-57.
 *
 * Note: operations that give feedback to the user, such as "Pause", are run at
 * regular speed.
 */
void penta7_advance(penta7_t *penta7, int ms, int speedup);

/** Should be called when a key is pressed (row in 0..7, col in 0..4). */
void penta7_key_press(penta7_t *penta7, int row, int col);

/** Should be called when a key is released. */
void penta7_key_release(penta7_t *penta7);

/**
 * The display as a string.
 *
 * The display is composed of 12 LEDs and each one is represented by 1
 * character (or 2 characters if there is an additional dot).
 *
 * Characters:
 * - legacy from TI-57: 'blank character' 0..9 A b C d E F -
 * - additional common characters: B D G..Z ( ) + /
 * - multiply: x (different from X)
 * - square root: v
 * - up arrow: ^ (for exponentiation)
 * - inverse: !
 * For example: "   02   vX  ".
 */
char *penta7_get_display(penta7_t *penta7);

#endif  /* !PENTA7_H */
