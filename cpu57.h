#ifndef CPU57_H
#define CPU57_H

#include <stdbool.h>

/** API for clients that want to implement a TI-57 emulator. */

/**
 * An internal register composed of 16 4-bit digits, decimal (0-9) or
 * hexadecimal (0-f).
 */
typedef unsigned char ti57_reg_t[16];

/** An 11-bit long address. */
typedef unsigned short ti57_address_t;

/** A 13-bit long opcode. */
typedef unsigned short ti57_opcode_t;

/** The state of a TI-57. */
typedef struct state_s {
    ti57_reg_t A, B, C, D;      // Operational Registers
    ti57_reg_t X[8], Y[8];      // Storage Registers
    unsigned char RAB;          // Register Address Buffer (3-bit)
    unsigned char R5;           // Auxiliary 8-bit Register
    ti57_address_t pc;          // Program Counter
    ti57_address_t stack[3];    // Subroutine Stack
    bool COND;                  // Conditional Latch
    bool is_hex;                // Arithmetic done in base 16 instead of 10
    bool key_pressed;           // A key is being pressed
    int row, col;               // Row and Column of key
    ti57_reg_t dA, dB;          // Copy of A and B for display purposes
} ti57_state_t;

/** Initializes the state of a TI-57. */
void ti57_init(ti57_state_t *s);

/** Executes 'n' instructions starting at s->pc. */
void ti57_burst(ti57_state_t *s, int n, ti57_opcode_t *rom);

/** Should be called when a key is pressed (row in 0..7, col in 0..4.). */
void ti57_key_press(ti57_state_t *s, int row, int col);

/** Should be called when a key is released. */
void ti57_key_release(ti57_state_t *s);

/** Returns the display as a string ('str' should be at least 25-char long). */
char *ti57_get_display(ti57_state_t *s, char *str);

#endif  /* !CPU57_H */
