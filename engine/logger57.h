/**
 * Updating of the log.
 */

#ifndef logger57_h
#define logger57_h

#include "state57.h"

/**
 * Updates the log using the current state of the calculator and comparing it to the previous one.
 *
 * Note: this function should be called after every call to 'next'.
 */
void logger57_update_after_next(ti57_t *ti57,
                                ti57_activity_t previous_activity,
                                ti57_mode_t previous_mode);

#endif /* logger57_h */
