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
typedef enum mode_e {
    EVAL,
    LRN,
    RUN
} mode_t;

/** Units for trigometric functions. */
typedef enum trig_e {
    DEG,
    RAD,
    GRAD,
} trig_t;

/**
 * Encodes one of the keys of the keyboard.
 *
 * Digit keys are encoded as 0x0d. Other keys are encoded by their location
 * (row, col) on the keyboard:
 * - most significant 4 bits: row in 1..8
 * - least significant 4 bits: column in 1..5 for primary keys and in 6..A for
 *   secondary keys
 */
typedef unsigned char key_t;

/**
 * An instruction with an optional inverse modifier and an optional paramater.
 *
 * The parameter 'd' is in 0..9 (-1 means there is no parameter).
 */
typedef struct instruction_s {
    bool_t inv;
    key_t key;
    signed char d;
} instruction_t;


/*******************************************************************************
 *
 * MODES
 *
 ******************************************************************************/

/** Main mode: EVAL, LRN or RUN. */
mode_t get_mode(state_t *s);

/** One of the 3 trigonometric units. */
trig_t get_trig(state_t *s);

/** Number of decimals after the decimal point. */
int get_fix(state_t *s);


/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

/** The '2nd' key has been pressed. */
bool_t is_2nd(state_t *s);

/** The 'INV' key has been pressed. */
bool_t is_inv(state_t *s);

/** Scientific notation is on. */
bool_t is_sci(state_t *s);

/** An error has occurred. */
bool_t is_error(state_t *s);

/** A number is being edited on the display. */
bool_t is_number_edit(state_t *s);

/** The display is blinking. */
bool_t is_blinking(state_t *s);

/** Mode is RUN and SST is pressed. */
bool_t is_trace(state_t *s);

/** Mode is RUN and R/S is pressed. */
bool_t is_stop(state_t *s);

/** A 'Pause' instruction is being executed (RUN or EVAL mode). */
bool_t is_paused(state_t *s);

/** An 'Ins' or 'Del' instruction is being executed (LRN mode). */
bool_t is_lrn_edit(state_t *s);

/**
 * The calculator is waiting for input, possibly blinking (LRN or EVAL mode).
 */
bool_t is_idle(state_t *s);


/*******************************************************************************
 *
 * AOS
 *
 ******************************************************************************/

/**
 * Returns the arithmetic stack coded as a sequence of characters:
 *   operands:
 *     '0'..'3': X[0]..X[3]
 *     'C': register C
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
char *get_aos_stack(state_t *s, char *str);


/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

/** One of the 8 user registers (i in 0..7). */
reg_t *get_reg(state_t *s, int i);

/** The X register. */
reg_t *get_regX(state_t *s);

/** The T register, same as user register 7. */
reg_t *get_regT(state_t *s);


/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

/** Program counter. */
int get_pc(state_t *s);

/** Subroutine return addresses (i in 0..1). */
int get_ret(state_t *s, int i);

/** Instruction at a given step (step in 0..49). */
instruction_t *get_instruction(state_t *s, int step);

#endif  /* !STATE57_H */
