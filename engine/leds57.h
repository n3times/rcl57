/**
 * Describes how to display, using a 14-segment LED, the characters used in the ASCII names
 * of keys of type key57_t.
 */

#ifndef leds57_h
#define leds57_h

/**
 * Indicates, for each character, which segments of a 14-segment LED are on.
 * Segments top to bottom, left to right: -|\|/|--|/|\|-
 */
int leds57_get_segments(unsigned char c);

#endif /* leds57_h */
