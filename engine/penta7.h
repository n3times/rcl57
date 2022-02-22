#ifndef PENTA7_H
#define PENTA7_H

#include "ti57.h"

/**
 *
 * API for clients that want to implement a Penta7 emulator, a calculator built
 * on top of TI-57.
 *
 * The goal of Penta7 is to maintain backward compatibility with TI-57 while
 * having options to improve the user experience.
 *
 * For a faithful emulation, use ti57.h instead.
 *
 * Sample implementation:
 *   Init:
 *     penta7_t penta7;
 *     penta7_init(&penta7);
 *     penta7.options = PENTA7_QUICK_STOP_FLAG | PENTA7_SHOW_RUN_INDICATOR_FLAG;
 *     penta7.speedup = 1000;
 *   On a timer, every 50ms:
 *     penta7_advance(penta7, 20);
 *     // 'update_display' should be defined by the client.
 *     update_display(penta7_get_display(&penta7))
 *   On key press:
 *     penta7_key_press(&penta7, row, col);
 *   On key release:
 *     penta7_key_release(&penta7);
 *
 */

/**
 * Option flags that modify/enhance the original TI-57.
 */

/** Pause for 1s instead of 2s. */
#define PENTA7_SHORT_PAUSE_FLAG                 0x01

/** On trace, pause at each instruction for 1s, instead of 2s. */
#define PENTA7_FASTER_TRACE_FLAG                0x02

/**
 * In RUN mode, stop right away when user presses 'R/S'.
 *
 * This option is highly recommended as the default experience (where the user
 * may need to press the 'R/S' for a couple of seconds) can be very frustrating.
 */
#define PENTA7_QUICK_STOP_FLAG                  0x04

/**
 * In RUN mode, show "[" instead of a garbled display.
 *
 * This is the behavior of the TI-59.
 *
 * This option is highly recommended esp. if the emulator is RUN at high speed.
 */
#define PENTA7_SHOW_RUN_INDICATOR_FLAG           0x08

/** In EVAL mode, show the arithmetic operator just entered. */
#define PENTA7_DISPLAY_ARITHMETIC_OPERATORS_FLAG 0x10

/**
 * In LRN mode, show the instruction just entered instead of the next one.
 *
 * This is the default behavior of classic HP calculators and arguably better.
 */
#define PENTA7_HP_LRN_MODE_FLAG                  0x20

/** In LRN mode, show instructions as alphanumeric mnemonics such as "LNX". */
#define PENTA7_MNEMONICS_LRN_MODE_FLAG           0x40

typedef struct penta7_s {
    ti57_t ti57;
    bool at_end_program;
    int options;
    unsigned int speedup;
} penta7_t;

/** Initializes a Penta7. */
void penta7_init(penta7_t *penta7);

/**
 * Runs the emulator for 'ms' milliseconds.
 *
 * Returns true if calculator is still animating.
 */
bool penta7_advance(penta7_t *penta7, int ms);

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
 * - additional common characters: B D G..Z ( ) + / >
 * - multiply: x (different from X)
 * - square root: v
 * - up arrow: ^ (for exponentiation)
 * - inverse: !
 * For example: "   02   vX  ".
 */
char *penta7_get_display(penta7_t *penta7);

/* Clears the state while preserving the options. */
void penta7_clear(penta7_t *penta7);

#endif  /* !PENTA7_H */
