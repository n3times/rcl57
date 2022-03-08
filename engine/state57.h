#ifndef state57_h
#define state57_h

#include <stdbool.h>

#include "key57.h"
#include "log57.h"

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


/**
 * Activities:
 * - TI57_POLL_KEY_PRESS: in a tight loop, waiting for a key press.
 * - TI57_POLL_KEY_RUN_RELEASE: in a tight loop, waiting for R/S release.
 * - TI57_POLL_KEY_RELEASE: in a tight loop, waiting for a key release.
 * - TI57_BLINK:  in a tight loop, waiting for a key press while display blinking
 * - TI57_PAUSE: 'Pause' is being executed
 * - TI57_LONG: Executing an expensive operation such as 'Del' and 'Ins'
 * - TI57_BUSY: default, running or executing some operation
 */
typedef enum ti57_activity_e {
    TI57_BUSY,
    TI57_POLL_KEY_PRESS,
    TI57_POLL_KEY_RELEASE,
    TI57_POLL_KEY_RUN_RELEASE,
    TI57_BLINK,
    TI57_PAUSE,
    TI57_LONG,
} ti57_activity_t;

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

/** Parsing state in mode EVAL. */
typedef enum ti57_parse_state_e {
    TI57_PARSE_DEFAULT,
    TI57_PARSE_NUMBER_EDIT,          // The number on the display is being edited.
    TI57_PARSE_OP_EDIT,              // The parameter of an instruction hasn't been entered.
} ti57_parse_state_t;

/** The state of a TI-57. */
typedef struct ti57_s {
    // The internal state of a TI-57.
    ti57_reg_t A, B, C, D;           // Operational Registers
    ti57_reg_t X[8], Y[8];           // Storage Registers
    unsigned char RAB;               // Register Address Buffer (3-bit)
    unsigned char R5;                // Auxiliary 8-bit Register
    ti57_address_t pc;               // Program Counter
    ti57_address_t stack[3];         // Subroutine Stack
    bool COND;                       // Conditional Latch
    bool is_hex;                     // Arithmetic done in base 16 instead of 10
    bool is_key_pressed;             // A key is being pressed
    int row, col;                    // Row and column of pressed key
    ti57_reg_t dA, dB;               // Copy of A and B for display purposes

    unsigned long current_cycle;     // The number of cycle the emulator has been running for
    unsigned long last_disp_cycle;   // The cycle DISP was executed last
    key57_t last_processed_key;   // The key that was last pressed by the user
    ti57_mode_t mode;                // The current mode
    ti57_parse_state_t parse_state;  // The current parse state
    ti57_activity_t activity;        // The current activity

    log57_t log;
} ti57_t;

/** Units for trigometric functions. */
typedef enum ti57_trig_e {
    TI57_DEG,
    TI57_RAD,
    TI57_GRAD,
} ti57_trig_t;

/**
 * An instruction with an optional inverse modifier and an optional paramater.
 *
 * The parameter 'd' is in 0..9 (-1 means there is no parameter).
 */
typedef struct ti57_instruction_s {
    bool inv;
    key57_t key;
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
bool ti57_is_instruction_lrn_edit(ti57_t *ti57);

/** An instruction with a digit argument is being edited in EVAL mode. */
bool ti57_is_instruction_eval_edit(ti57_t *ti57);

/** 'SST' is pressed while in RUN mode. */
bool ti57_is_trace(ti57_t *ti57);

/** 'R/S' is pressed while in RUN mode. */
bool ti57_is_stopping(ti57_t *ti57);

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

/**
 * Gets the last operation in EVAL mode.
 */
char *ti57_get_current_op(ti57_t *ti57);

#endif  /* !state57_h */
