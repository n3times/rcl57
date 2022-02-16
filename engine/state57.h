#ifndef STATE57_H
#define STATE57_H

#include <stdbool.h>

/**
 * Internal state of a TI-57 and API to decode it.
 */

/**
 * Type for internal registers.
 *
 * Internal registers are composed of 16 4-bit digits which can be  decimal 0..9
 * or hexadecimal 0-F.
 */
typedef unsigned char ti57_reg_t[16];

/** Type for an 11-bit address (the ROM has 2^11 instructions). */
typedef unsigned short ti57_address_t;

/** The internal state of a TI-57. */
typedef struct ti57_s {
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
} ti57_t;

/**
 * Calculator modes:
 * - TI57_EVAL: executing or ready to execute user instructions
 * - TI57_LRN: user program is being edited
 * - TI57_RUN: user program is running
 */
typedef enum ti57_mode_e {
    TI57_EVAL,
    TI57_LRN,
    TI57_RUN
} ti57_mode_t;

/** Units for trigometric functions. */
typedef enum ti57_trig_e {
    TI57_DEG,
    TI57_RAD,
    TI57_GRAD,
} ti57_trig_t;

/**
 * Activities:
 * - TI57_POLL: in a tight loop, polling for user input (key press or key
 *   release)
 * - TI57_BLINK: similar to TI57_POLL but, in addition, the display blinking
 *   due to an error
 * - TI57_PAUSE: 'Pause' is being executed for ~2s
 * - TI57_LONG: Executing an expensive operation such as 'Del' and 'Ins'
 * - TI57_BUSY: default, running or executing some operation
 */
typedef enum ti57_activity_e {
    TI57_POLL,
    TI57_BLINK,
    TI57_PAUSE,
    TI57_LONG,
    TI57_BUSY,
} ti57_activity_t;

/**
 * Encodes one of the keys of the keyboard.
 *
 * Digit keys are encoded as 0x0d. Other keys are encoded by their location
 * (row, col) on the keyboard:
 * - most significant 4 bits: row in 1..8
 * - least significant 4 bits: column in 1..5 for primary keys and in 6..A for
 *   secondary keys
 */
typedef unsigned char ti57_key_t;

/**
 * An instruction with an optional inverse modifier and an optional paramater.
 *
 * The parameter 'd' is in 0..9 (-1 means there is no parameter).
 */
typedef struct ti57_instruction_s {
    bool inv;
    ti57_key_t key;
    signed char d;
} ti57_instruction_t;

/*******************************************************************************
 *
 * MODES
 *
 ******************************************************************************/

/** Current mode. */
ti57_mode_t ti57_get_mode(ti57_t *ti57);

/** Current trigonometric unit. */
ti57_trig_t ti57_get_trig(ti57_t *ti57);

/** Number of decimals after the decimal point (0..9). */
int ti57_get_fix(ti57_t *ti57);

/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

/** The '2nd' key has been registered in EVAL or LRN mode. */
bool ti57_is_2nd(ti57_t *ti57);

/** The 'INV' key has been registered in EVAL or LRN mode. */
bool ti57_is_inv(ti57_t *ti57);

/** Scientific notation is on. */
bool ti57_is_sci(ti57_t *ti57);

/** An error has occurred. */
bool ti57_is_error(ti57_t *ti57);

/** A number is being edited on the display. */
bool ti57_is_number_edit(ti57_t *ti57);

/** An instruction with a digit argument is being edited in LRN mode. */
bool ti57_is_instruction_edit(ti57_t *ti57);

/** 'SST' is pressed while in RUN mode. */
bool ti57_is_trace(ti57_t *ti57);

/** 'R/S' is pressed while in RUN mode. */
bool ti57_is_stopping(ti57_t *ti57);

/** Reports the current activity. */
ti57_activity_t ti57_get_activity(ti57_t *ti57);

/*******************************************************************************
 *
 * AOS
 *
 ******************************************************************************/

/**
 * Returns the arithmetic stack coded as a sequence of characters:
 *   operands:
 *     '0'..'3': X[0]..X[3]
 *     'X': X register
 *     'd': value on display
 *   straight operators:
 *     '+', 'x' and '^' (exponentiation)
 *   inverse operators:
 *     '-', '/' and 'v' (root extraction)
 *   open parenthesis:
 *     '('
 * For example "0+1*(2+d"
 */
char *ti57_get_aos_stack(ti57_t *ti57);

/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

/** One of the 8 user registers (i in 0..7). */
ti57_reg_t *ti57_get_reg(ti57_t *ti57, int i);

/** The X register. */
ti57_reg_t *ti57_get_regX(ti57_t *ti57);

/** The T register, same as user register 7. */
ti57_reg_t *ti57_get_regT(ti57_t *ti57);

/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

/** Program counter: 0..50 even if only steps 0..49 are valid. */
int ti57_get_pc(ti57_t *ti57);

/** Subroutine return addresses (i in 0..1). */
int ti57_get_ret(ti57_t *ti57, int i);

/** Instruction at a given step (step in 0..49). */
ti57_instruction_t *ti57_get_instruction(ti57_t *ti57, int step);

#endif  /* !STATE57_H */
