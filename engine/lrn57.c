#include "lrn57.h"

#include <string.h>

#include "op57.h"
#include "utils57.h"

static void clear_op_edit_flag(ti57_t *ti57)
{
    ti57->C[14] &= 0xe;
}

static void clear_2nd_flag(ti57_t *ti57)
{
    ti57->C[14] &= 0x7;
}

static void set_2nd_flag(ti57_t *ti57)
{
    ti57->C[14] |= 0x8;
}

static void clear_inv_flag(ti57_t *ti57)
{
    ti57->B[15] &= 0xb;
}

static void set_inv_flag(ti57_t *ti57)
{
    ti57->B[15] |= 0x4;
}

/**
 *
 */

static void press_key(ti57_t *ti57, bool sec, int row, int col)
{
    if (sec) {
        set_2nd_flag(ti57);
    } else {
        clear_2nd_flag(ti57);
    }
    ti57_key_press(ti57, row, col);
    utils57_burst_until_idle(ti57);
    ti57_key_release(ti57);
    utils57_burst_until_idle(ti57);
}

static void press_key_lrn(ti57_t *ti57)
{
    press_key(ti57, false, 2, 1);
}

static void press_key_sst(ti57_t *ti57)
{
    press_key(ti57, false, 3, 1);
}

static void press_key_bst(ti57_t *ti57)
{
    press_key(ti57, false, 4, 1);
}

static void press_key_ins(ti57_t *ti57)
{
    press_key(ti57, true, 3, 2);
}

static void press_key_del(ti57_t *ti57)
{
    press_key(ti57, true, 4, 2);
}

/**
 * EDIT KEYS
 */

// Note that, in HP-mode, the step being displayed is not necessarily
// the one at pc. It is the one at pc - 1, except when we are 'at_end_program'
// or when an operation is being edited. This explains the intricate logic
// necessary for the edit keys to function the way the user would expect.

// Displays the step previous to the one currently displayed.
static void handle_bst(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (rcl57->at_end_program) {
        // No need to decrement pc.
        rcl57->at_end_program = false;
        // Step displayed: 49 -> 48
    } else if (ti57_is_op_edit_in_lrn(ti57)) {
        // No need to decrement pc.
        clear_op_edit_flag(ti57);
        // Step displayed: pc -> pc - 1.
    } else if (ti57_get_program_pc(ti57) > 0) {
        press_key_bst(ti57);
        // Step displayed: pc - 1 -> pc - 2 (or 0 -> 'Lrn' if pc == 1).
    } else {
        // Already at the beginning with pc == 0 and 'Lrn' displayed.
    }
}

// Displays the step following the one currently displayed.
static void handle_sst(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (rcl57->at_end_program) {
        // Nothing.
    } else if (ti57_is_op_edit_in_lrn(ti57)) {
        int pc = ti57_get_program_pc(ti57);
        clear_op_edit_flag(ti57);
        if (pc == 49) {
            // No need to increment pc.
            rcl57->at_end_program = true;
        } else if (pc == 48) {
            press_key_sst(ti57);
            rcl57->at_end_program = true;
        } else {
            press_key_sst(ti57);
            press_key_sst(ti57);
            // Step displayed: pc -> pc + 1 (even if pc -> pc + 2).
        }
    } else if (ti57_get_program_pc(ti57) == 49) {
        // No need to increment pc.
        rcl57->at_end_program = true;
    } else {
        press_key_sst(ti57);
    }
}

// Deletes the step currently displayed, displaying the previous step.
static void handle_del(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (rcl57->at_end_program) {
        rcl57->at_end_program = false;
        press_key_del(ti57);
    } else if (ti57_is_op_edit_in_lrn(ti57)) {
        clear_op_edit_flag(ti57);
        press_key_del(ti57);
    } else if (ti57_get_program_pc(ti57) > 0) {
        // Decrement pc, since the step being displayed is pc - 1.
        press_key_bst(ti57);
        press_key_del(ti57);
    } else {
        // The user is seeing 'Lrn'. Do not delete.
    }
}

// Note that classic HP calculators do not have an insert key.
static void handle_ins(rcl57_t *rcl57)
{
    // Nothing.
}

static void handle_lrn(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    press_key_lrn(ti57);
}

/**
 * API IMPLEMENTATION
 */

void lrn57_key_press_in_hp_mode(rcl57_t *rcl57, int row, int col)
{
    ti57_t *ti57 = &rcl57->ti57;
    bool is_2nd, is_inv;
    key57_t pressed_key = key57_get_key(row, col, false);

    // Handle modifiers.
    if (pressed_key == KEY57_2ND || pressed_key == KEY57_INV) {
        return ti57_key_press(&rcl57->ti57, row, col);
    }
    is_2nd = ti57_is_2nd(ti57);
    is_inv = ti57_is_inv(ti57);
    clear_2nd_flag(ti57);
    clear_inv_flag(ti57);

    // Handle editing keys.
    pressed_key = key57_get_key(row, col, is_2nd);
    if (pressed_key == KEY57_BST) {
        return handle_bst(rcl57);
    } else if (pressed_key == KEY57_SST) {
        return handle_sst(rcl57);
    } else if (pressed_key == KEY57_INS) {
        return handle_ins(rcl57);
    } else if (pressed_key == KEY57_DEL) {
        return handle_del(rcl57);
    } else if (pressed_key == KEY57_LRN) {
        return handle_lrn(rcl57);
    }

    // No op if we are already at the end of the program.
    if (rcl57->at_end_program) {
        return;
    }

    // Insert instead of overriding in HP mode.
    if (!ti57_is_op_edit_in_lrn(ti57)) {
        press_key_ins(ti57);
    }

    // Handle key.
    if (is_inv) {
        set_inv_flag(ti57);
    }
    press_key(ti57, is_2nd, row, col);

    // HACK: Go back to LRN mode, if we are at the end of the program and in EVAL mode.
    if (ti57->mode == TI57_EVAL) {
        press_key_lrn(ti57);
        rcl57->at_end_program = true;
    }
    return;
}

char *lrn57_get_display(rcl57_t *rcl57)
{
    static char str[25];
    ti57_t *ti57 = &rcl57->ti57;
    int pc = ti57_get_program_pc(ti57);
    bool op_pending = ti57_is_op_edit_in_lrn(ti57);
    bool is_hp_mode = rcl57->options & RCL57_HP_LRN_MODE_FLAG;
    bool is_alphanumeric_mode = rcl57->options & RCL57_ALPHA_LRN_MODE_FLAG;
    int dot_count = 0;

    if (pc == 0 && !op_pending && is_hp_mode) {
        return is_alphanumeric_mode ? " LRN        " : " Lrn        ";
    }

    if (!op_pending && !rcl57->at_end_program && is_hp_mode) {
        pc -= 1;
    }

    op57_t *op = ti57_get_program_op(ti57, pc);

    memset(str, ' ', sizeof(str));
    str[sizeof(str) - 1] = 0;

    // Set operation.
    int i = (int)strlen(str) - 1;
    if (op->d >= 0) {
        str[i] = '0' + op->d;
        i -= 2;
    } else if (op_pending) {
        str[i] = is_alphanumeric_mode ? '_' : '0';
        i -= 2;
    } else if (!is_alphanumeric_mode) {
        i -= 2;
    }
    if (is_alphanumeric_mode) {
        char *name = key57_get_ascii_name(op->key);
        for (int j = (int)strlen(name) - 1; j >= 0; j--) {
            str[i--] = name[j];
            if (str[i + 1] == '.') {
                str[i--] = ' ';
                dot_count += 1;
            }
        }
    } else {
        str[i--] = '0' + op->key % 16;
        str[i--] = '0' + op->key / 16;
    }
    if (op->inv) {
        if (is_alphanumeric_mode) {
            memcpy(str + i - 3, "INV", 3);
        } else {
            str[i] = '-';
        }
    }

    // Set step number.
    char s1 = '0' + pc / 10;
    char s2 = '0' + pc % 10;
    int start = 12 - dot_count;
    if (is_alphanumeric_mode) {
        str[start] = s1;
        str[start + 1] = s2;
    } else {
        str[start + 4] = s1;
        str[start + 5] = s2;
    }

    return str + start;
}
