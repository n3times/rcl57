#ifndef STATE57_H
#define STATE57_H

/**
 * API for decoding the internal registers of the TI-57.
 */

/**
 * Calculator modes:
 * - RUN: user program is running
 * - LRN: user program is being edited
 * - EVAL otherwise
 */
typedef enum ti57_mode_e {
    TI57_EVAL,
    TI57_LRN,
    TI57_RUN
} ti57_mode_t;

/** Units for trigometric functions. */
typedef enum trig_e {
    TI57_DEG,
    TI57_RAD,
    TI57_GRAD,
} ti57_trig_t;

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

/** Main mode: EVAL, LRN or RUN. */
ti57_mode_t ti57_get_mode(ti57_state_t *s);

/** One of the 3 trigonometric units. */
ti57_trig_t ti57_get_trig(ti57_state_t *s);

/** Number of decimals after the decimal point. */
int ti57_get_fix(ti57_state_t *s);

/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

/** The '2nd' key has been pressed. */
bool ti57_is_2nd(ti57_state_t *s);

/** The 'INV' key has been pressed. */
bool ti57_is_inv(ti57_state_t *s);

/** Scientific notation is on. */
bool ti57_is_sci(ti57_state_t *s);

/** An error has occurred. */
bool ti57_is_error(ti57_state_t *s);

/** A number is being edited on the display. */
bool ti57_is_number_edit(ti57_state_t *s);

/** The display is blinking. */
bool ti57_is_blinking(ti57_state_t *s);

/** Mode is RUN and SST is pressed. */
bool ti57_is_trace(ti57_state_t *s);

/** Mode is RUN and R/S is pressed. */
bool ti57_is_stopping(ti57_state_t *s);

/** A 'Pause' instruction is being executed (RUN or EVAL mode). */
bool ti57_is_paused(ti57_state_t *s);

/** An 'Ins' or 'Del' instruction is being executed (LRN mode). */
bool ti57_is_lrn_edit(ti57_state_t *s);

/**
 * The calculator is waiting for input, possibly blinking (LRN or EVAL mode).
 */
bool ti57_is_idle(ti57_state_t *s);

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
 *     '+', '*' and '^'
 *   inverse operators:
 *     '-', '/' and 'v'
 *   open parenthesis:
 *     '('
 * For example "0+1*(2+d"
 *
 * 'str' must hold 45 characters at least.
 * Returns 'str'.
 */
char *ti57_get_aos_stack(ti57_state_t *s, char *str);

/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

/** One of the 8 user registers (i in 0..7). */
ti57_reg_t *ti57_get_reg(ti57_state_t *s, int i);

/** The X register. */
ti57_reg_t *ti57_get_regX(ti57_state_t *s);

/** The T register, same as user register 7. */
ti57_reg_t *ti57_get_regT(ti57_state_t *s);

/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

/** Program counter. */
int ti57_get_pc(ti57_state_t *s);

/** Subroutine return addresses (i in 0..1). */
int ti57_get_ret(ti57_state_t *s, int i);

/** Instruction at a given step (step in 0..49). */
ti57_instruction_t *ti57_get_instruction(ti57_state_t *s, int step);

#endif  /* !STATE57_H */
