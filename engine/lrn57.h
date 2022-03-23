/**
 * Supports enhanced LRN mode (alphanumeric and HP style).
 */

#ifndef lrn57_h
#define lrn57_h

#include "rcl57.h"

/** Returns a string representing the display in enhanced LRN mode. */
char *lrn57_get_display(rcl57_t *rcl57);

/** Handles a key press in HP LRN mode (row in 1..8, col in 1..5). */
void lrn57_key_press_in_hp_mode(rcl57_t *rcl57, int row, int col);

#endif /* lrn57_h */
