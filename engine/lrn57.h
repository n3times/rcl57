#ifndef lrn57_h
#define lrn57_h

#include "rcl57.h"

/**
 * Returns a string representing
 */
char *get_display_in_special_lrn_mode(rcl57_t *rcl57);

void key_press_in_hp_lrn_mode(rcl57_t *rcl57, int row, int col);

#endif /* lrn57_h */
