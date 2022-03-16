/**
 * Update the log.
 */

#ifndef logger57_h
#define logger57_h

#include "state57.h"

/**
 * Updates the log using the current state of the calculator and comparing it to the previous one.
 *
 * Note: to be effective this function should affect ever call to 'next'.
 */
void log57_update_after_next(ti57_t *ti57,
                             ti57_activity_t previous_activity,
                             ti57_mode_t previous_mode);

#endif /* logger57_h */
