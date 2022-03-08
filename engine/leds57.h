#ifndef leds57_h
#define leds57_h

/**
 * Indicates, for each character, which segments of a 14-segment LED are on.
 * Segments top to bottom, left to right: -|\|/|--|/|\|-
 */
int leds57_get_segments(char c);

#endif /* leds57_h */
