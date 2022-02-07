#ifndef leds_h
#define leds_h

// Indicates, for each character, which segments of a 14-segment LED are on.
// Segments top to bottom, left to right: -|\|/|--|/|\|-
int get_led_segments(char c);

#endif /* leds_h */
