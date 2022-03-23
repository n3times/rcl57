/**
 * Internal state of a TI-57 and API to decode it.
 */

#ifndef state57_h
#define state57_h

#include <stdbool.h>

#include "key57.h"
#include "log57.h"

/**
 * Type for internal registers.
 *
 * Internal registers are composed of 16 4-bit digits. Depending on the context,
 * the range of the digits can be  decimal 0..9 or hexadecimal 0..F.
 */
typedef unsigned char ti57_reg_t[16];

/** Type for an 11-bit address (the ROM has 2^11 instructions). */
typedef unsigned short ti57_address_t;

/** Describes the activity state (busy or idle) of the TI-57. */
typedef enum ti57_activity_e {
    TI57_BUSY,              // Default, running or executing some operation.
    TI57_POLL_PRESS,        // In a tight loop, waiting for a key press.
    TI57_POLL_PRESS_BLINK,  // In a tight loop, waiting for a key press while display is blinking.
    TI57_POLL_RELEASE,      // In a tight loop, waiting for a key release.
    TI57_POLL_RS_RELEASE,   // In a tight loop, waiting for R/S release.
    TI57_PAUSE,             // 'Pause' is being executed.
} ti57_activity_t;

/** Calculator modes. */
typedef enum ti57_mode_e {
    TI57_EVAL,  // Executing or ready to execute user operations.
    TI57_LRN,   // User program is being edited.
    TI57_RUN    // User program is running.
} ti57_mode_t;

/** Parsing state in mode EVAL. */
typedef enum ti57_parse_state_e {
    TI57_PARSE_DEFAULT,      // No parsing is occurring.
    TI57_PARSE_NUMBER_EDIT,  // The number on the display is being edited.
    TI57_PARSE_OP_EDIT,      // The parameter of an operation hasn't been entered.
} ti57_parse_state_t;

/** Units for trigometric functions. */
typedef enum ti57_trig_e {
    TI57_DEG,
    TI57_RAD,
    TI57_GRAD,
} ti57_trig_t;

/** The state of a TI-57. */
typedef struct ti57_s {
    // The internal state of a TI-57.
    ti57_reg_t A, B, C, D;           // Operational registers.
    ti57_reg_t X[8], Y[8];           // Storage registers.
    unsigned char RAB;               // Register address buffer (3-bit).
    unsigned char R5;                // Auxiliary 8-bit register.
    ti57_address_t pc;               // Internal program counter.
    ti57_address_t stack[3];         // Subroutine stack.
    bool COND;                       // Conditional latch.
    bool is_hex;                     // Arithmetic done in base 16 instead of 10.
    int row, col;                    // Row (1..8) and column (1..5) of last pressed key.
    bool is_key_pressed;             // Whether a key is being pressed by the user.

    ti57_reg_t dA, dB;               // Copy of A and B for display purposes.
    unsigned long current_cycle;     // The number of cycles the emulator has been running for.
    unsigned long last_disp_cycle;   // The cycle DISP was executed last.
    ti57_mode_t mode;                // The current mode.
    ti57_parse_state_t parse_state;  // The current parse state.
    ti57_activity_t activity;        // The current activity.
    int step_at_key_press;           // Use for SST (single step).

    log57_t log;                     // The sequence of user operations and results.
} ti57_t;

/**
 * MODES
 */

/** Current mode. */
ti57_mode_t ti57_get_mode(ti57_t *ti57);

/** Current trigonometric unit. */
ti57_trig_t ti57_get_trig(ti57_t *ti57);

/** Number of decimals after the decimal point (0..9). */
int ti57_get_fix(ti57_t *ti57);

/**
 * FLAGS
 */

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

/** An operation with a digit argument is being edited in LRN mode. */
bool ti57_is_op_edit_in_lrn(ti57_t *ti57);

/** An operation with a digit argument is being edited in EVAL mode. */
bool ti57_is_op_edit_in_eval(ti57_t *ti57);

/** 'SST' is pressed while in RUN mode. */
bool ti57_is_trace(ti57_t *ti57);

/** 'R/S' is pressed while in RUN mode. */
bool ti57_is_stopping(ti57_t *ti57);

/**
 * AOS
 */

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

/**
 * USER REGISTERS
 */

/** One of the 8 user registers (i in 0..7). */
ti57_reg_t *ti57_get_user_reg(ti57_t *ti57, int i);

/** The X register. */
ti57_reg_t *ti57_get_regX(ti57_t *ti57);

/** The T register, same as user register 7. */
ti57_reg_t *ti57_get_regT(ti57_t *ti57);

/**
 * USER PROGRAM
 */

/** Program counter: 0..50 even if only steps 0..49 are valid. */
int ti57_get_user_pc(ti57_t *ti57);

/** Subroutine return addresses (i in 0..1). */
int ti57_get_ret(ti57_t *ti57, int i);

/** Operation at a given step (step in 0..49). */
op57_op_t *ti57_get_op(ti57_t *ti57, int step);

#endif  /* !state57_h */
