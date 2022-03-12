/**
 * API for clients that want to implement a RCL57 emulator, a calculator built
 * on top of TI-57.
 *
 * The goal of RCL57 is to maintain backward compatibility with TI-57 while
 * having options to improve the user experience.
 *
 * For a faithful emulation, use ti57.h instead.
 *
 * Sample implementation:
 *   Init:
 *     rcl57_t rcl57;
 *     rcl57_init(&rcl57);
 *     rcl57.options = RCL57_QUICK_STOP_FLAG | RCL57_SHOW_RUN_INDICATOR_FLAG;
 *     rcl57.speedup = 1000;
 *   On a timer, every 50ms:
 *     rcl57_advance(rcl57, 20);
 *     // 'update_display' should be defined by the client.
 *     update_display(rcl57_get_display(&rcl57))
 *   On key press:
 *     rcl57_key_press(&rcl57, row, col);
 *   On key release:
 *     rcl57_key_release(&rcl57);
 */

#ifndef rcl57_h
#define rcl57_h

#include "ti57.h"

/**
 * Option flags that modify/enhance the original TI-57.
 */

/** Pause for 1s instead of 2s. */
#define RCL57_SHORT_PAUSE_FLAG                 0x01

/** On trace, pause at each instruction for 1s, instead of 2s. */
#define RCL57_FASTER_TRACE_FLAG                0x02

/**
 * In RUN mode, stop right away when user presses 'R/S'.
 *
 * This option is highly recommended as the default experience (where the user
 * may need to press the 'R/S' for a couple of seconds) can be very frustrating.
 */
#define RCL57_QUICK_STOP_FLAG                  0x04

/**
 * In RUN mode, show "[" instead of a garbled display.
 *
 * This is the behavior of the TI-59.
 *
 * This option is highly recommended esp. if the emulator is RUN at high speed.
 */
#define RCL57_SHOW_RUN_INDICATOR_FLAG           0x08

/** In EVAL mode, show the arithmetic operator just entered. */
#define RCL57_DISPLAY_ARITHMETIC_OPERATORS_FLAG 0x10

/**
 * In LRN mode, show the instruction just entered instead of the next one.
 *
 * This is the default behavior of classic HP calculators and arguably better.
 */
#define RCL57_HP_LRN_MODE_FLAG                  0x20

/** In LRN mode, show instructions as alphanumeric mnemonics such as "LNX". */
#define RCL57_ALPHANUMERIC_LRN_MODE_FLAG        0x40

typedef struct rcl57_s {
    ti57_t ti57;
    bool at_end_program;
    int options;
    unsigned int speedup;
} rcl57_t;

/** Initializes a RCL57. */
void rcl57_init(rcl57_t *rcl57);

/**
 * Runs the emulator for 'ms' milliseconds.
 *
 * Returns true if calculator is still animating.
 */
bool rcl57_advance(rcl57_t *rcl57, int ms);

/** Should be called when a key is pressed (row in 1..8, col in 1..5). */
void rcl57_key_press(rcl57_t *rcl57, int row, int col);

/** Should be called when a key is released. */
void rcl57_key_release(rcl57_t *rcl57);

/**
 * Returns the display as a string.
 *
 * The display is composed of 12 LEDs and each one is represented by 1
 * character (or 2 characters if there is an additional dot).
 *
 * Characters:
 * - legacy from TI-57: 'blank character' 0..9 A b C d E F - and .
 * - the rest of the uppercase letters
 * - arithmetic operators ( ) + - x / ^ = with '^' for exponentiation
 * - square root: v
 * - greater or equal: >
 * - stats: s for uppercase sigma, @ for average, g for lower case sigma
 * For example: "   02   vX  ".
 */
char *rcl57_get_display(rcl57_t *rcl57);

/* Clears the state while preserving the options. */
void rcl57_clear(rcl57_t *rcl57);

#endif  /* !rcl57_h */
