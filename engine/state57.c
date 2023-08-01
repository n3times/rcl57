#include "state57.h"
#include "utils57.h"

#include <assert.h>
#include <string.h>

/**
 * MODES
 */

ti57_mode_t ti57_get_mode(ti57_t *ti57)
{
    return ti57->mode;
}

ti57_trig_t ti57_get_trig(ti57_t *ti57)
{
    if ((ti57->X[4][15] & 0xC) == 0xC) return TI57_GRAD;
    if ((ti57->X[4][15] & 0xC) == 0x4) return TI57_RAD;

    return TI57_DEG;
}

int ti57_get_fix(ti57_t *ti57)
{
    return 9 - ti57->X[4][14];
}

/**
 * FLAGS
 */

bool ti57_is_2nd(ti57_t *ti57)
{
    if (ti57->mode == TI57_RUN) return false;

    key57_t current_key = key57_get_key(ti57->row, ti57->col, false);
    if (current_key != KEY57_2ND && current_key != KEY57_INV) {
        return false;
    }

    return (ti57->C[14] & 0x8) != 0;
}

bool ti57_is_inv(ti57_t *ti57)
{
    if (ti57->mode == TI57_RUN) return false;

    key57_t current_key = key57_get_key(ti57->row, ti57->col, false);
    if (current_key != KEY57_2ND && current_key != KEY57_INV) {
        return false;
    }

    return (ti57->B[15] & 0x4) != 0;
}

bool ti57_is_error(ti57_t *ti57)
{
    if (ti57->mode != TI57_EVAL) return false;

    return (ti57->B[15] & 0x2) != 0;
}

bool ti57_is_sci(ti57_t *ti57)
{
    return (ti57->B[15] & 0x8) != 0;
}

bool ti57_is_number_edit(ti57_t *ti57)
{
    return (ti57->B[15] & 0x1) != 0;
}

bool ti57_is_op_edit_in_lrn(ti57_t *ti57)
{
    if (ti57->mode != TI57_LRN) return false;
    if (key57_get_key(ti57->row, ti57->col, false) == KEY57_LRN) return false;

    return (ti57->C[14] & 0x1) != 0;
}

bool ti57_is_op_edit_in_eval(ti57_t *ti57)
{
    if (ti57->mode != TI57_EVAL) return false;

    return ti57->stack[0] == 0x00c9 || ti57->stack[1] == 0x00c9 ||  // Reg op or Fix
           ti57->stack[0] == 0x033f || ti57->stack[1] == 0x033f;    // GTO or SBR
}

bool ti57_is_trace(ti57_t *ti57)
{
    if (ti57->mode != TI57_RUN) return false;
    if (!ti57->is_key_pressed) return false;

    return key57_get_key(ti57->row, ti57->col, false) == KEY57_SST;
}

bool ti57_is_stopping(ti57_t *ti57)
{
    if (ti57->mode != TI57_RUN) return false;
    if (!ti57->is_key_pressed) return false;

    return key57_get_key(ti57->row, ti57->col, false) == KEY57_RS;
}

/**
 * AOS
 */

char *ti57_get_aos_stack(ti57_t *ti57)
{
    static char str[46];  // longest example: "0+((((((((((1+((((((((((2+((((((((((3+((((((((((4"
    int k = 0;
    int num_operands = 0;

    if (ti57->X[0][14] != 0) {
        num_operands = ti57->D[15] + 1;
    }

    // Initial opening parentheses.
    if (num_operands == 0) {
        int num_parentheses = ti57->X[0][15];
        for (int i = 0; i < num_parentheses; i++) {
            str[k++] = '(';
        }
    }

    // List of [operand, operator, parentheses]
    for (int i = 0; i < num_operands; i++) {
        bool inv = (ti57->X[i][13] & 0x4) != 0;
        str[k++] = '0' + i;
        switch(ti57->X[i][14]) {
            case 2: str[k++] = inv ? '-' : '+'; break;
            case 4: str[k++] = inv ? '/' : 'x'; break;
            case 8: str[k++] = inv ? 'v' : '^'; break;
            default: str[k++] = '?';
        }
        for (int j = 0; j < ti57->X[i][15]; j++) {
            str[k++] = '(';
        }
    }

    // Optional last operand.
    if (ti57->B[15] & 0x1) {
        str[k++] = 'd';  // display
    } else if ((ti57->C[14] & 0x2) == 0) {
        str[k++] = 'X';  // regX
    }

    str[k++] = 0;
    return str;
}

/**
 * USER REGISTERS
 */

ti57_reg_t *ti57_get_user_reg(ti57_t *ti57, int i)
{
    assert(0 <= i && i <= 7);

    switch(i) {
    case 0: return &ti57->X[5];
    case 1: return &ti57->X[6];
    case 2: return &ti57->X[7];
    case 3: return &ti57->Y[6];
    case 4: return &ti57->Y[7];
    case 5: return &ti57->X[3];  // Shared with AOS stack
    case 6: return &ti57->X[2];  // Shared with AOS stack
    case 7: return &ti57->X[4];  // Shared with regT

    default: return 0;
    }
}

ti57_reg_t *ti57_get_regX(ti57_t *ti57)
{
    // TODO: is this correct?
    return &ti57->C;
}

ti57_reg_t *ti57_get_regT(ti57_t *ti57)
{
    return &ti57->X[4];
}

int ti57_get_registers_last_index(ti57_t *ti57)
{
    int last_index = 7;
    while (last_index >= 0 && (*ti57_get_user_reg(ti57, last_index))[12] == 0) {
        last_index -= 1;
    }
    return last_index;
}

void ti57_clear_registers(ti57_t *ti57)
{
    for (int i = 0; i < 8; i++) {
        ti57_reg_t *reg = ti57_get_user_reg(ti57, i);
        memset(reg, 0, 14 * sizeof(unsigned char));
    }
}

/**
 * USER PROGRAM
 */

int ti57_get_program_pc(ti57_t *ti57)
{
    int pc = (ti57->X[5][15] << 4) + ti57->X[5][14];

    if (pc > 49) pc = 49;
    return pc;
}

int ti57_get_program_ret(ti57_t *ti57, int i)
{
    assert(0 <= i && i <= 1);

    return (ti57->X[6 + i][15] << 4) + ti57->X[6 + i][14];
}

static op57_t ALL_OPS[256];

static void init_ops(void)
{
    for (int i = 0; i <= 0xff; i++) {
        op57_t *op = &ALL_OPS[i];
        if (i < 0x10) {
            // Digits.
            op->inv = false;
            op->key = i;
            op->d = -1;
        } else if (i < 0xb0) {
            // Ops with no parameters.
            op->inv = (i & 0x08) != 0;
            op->key = (((i & 0x07) + 1) << 4) | (i & 0xf0) >> 4;
            op->d = -1;
        } else {
            // Register ops: RCL, PRD, SUM, EXC and STO.
            static key57_t keys[] = {0x33, 0x38, 0x34, 0x39, 0x32};
            op->inv = (i & 0x08) != 0;
            op->key = keys[(i >> 4) - 0xb];
            op->d = i & 0x07;
        }
    }

    // LBL, GTO, SBR and FIX.
    static int start_indices[] = {0x27, 0x2f, 0x77, 0x7f};
    static key57_t keys[] = {0x86, 0x51, 0x61, 0x48};
    static int offsets[] = {0, -1, 15, 31, -2, 14, 30, -3, 13, 29};
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 10; j++) {
            op57_t *op = &ALL_OPS[start_indices[i] + offsets[j]];
            op->inv = false;
            op->key = keys[i];
            op->d = j;
        }
    }
}

static op57_t *get_op(unsigned char index)
{
    return &ALL_OPS[index];
}

op57_t *ti57_get_program_op(ti57_t *ti57, int step)
{
    int i;
    ti57_reg_t *reg;
    static bool initialized = false;

    assert(0 <= step && step <= 49);

    if (!initialized) {
        init_ops();
        initialized = true;
    }
    if (step == 49) {
        reg = &ti57->Y[7];
        i = 15;
    } else {
        reg = &ti57->Y[step / 8];
        i = 15 - 2 * (step % 8);
    }
    return get_op(((*reg)[i] << 4) | (*reg)[i-1]);
}

int ti57_get_program_last_index(ti57_t *ti57)
{
    int last_index = 49;
    while (last_index >= 0 && ti57_get_program_op(ti57, last_index)->key == 0) {
        last_index -= 1;
    }
    return last_index;
}

void ti57_clear_program(ti57_t *ti57)
{
    // Get out of LRN mode (by pressing LRN) if necessary.
    if (ti57_get_mode(ti57) == TI57_LRN) {
        if (ti57_is_2nd(ti57)) {
            ti57_key_press(ti57, 1, 1);
            utils57_burst_until_idle(ti57);
            ti57_key_release(ti57);
            utils57_burst_until_idle(ti57);
        }
        ti57_key_press(ti57, 2, 1);
        utils57_burst_until_idle(ti57);
        ti57_key_release(ti57);
        utils57_burst_until_idle(ti57);
    }

    // Clear steps.
    for (int i = 0; i <= 5; i++) {
        memset(ti57->Y[i], 0, sizeof(ti57_reg_t));
    }
    memset(&ti57->Y[6][15], 0, sizeof(unsigned char));
    memset(&ti57->Y[6][14], 0, sizeof(unsigned char));
    memset(&ti57->Y[7][15], 0, sizeof(unsigned char));
    memset(&ti57->Y[7][14], 0, sizeof(unsigned char));

    // Set pc to 0.
    memset(&ti57->X[5][15], 0, sizeof(unsigned char));
    memset(&ti57->X[5][14], 0, sizeof(unsigned char));

    if (ti57_is_op_edit_in_lrn(ti57)) {
        ti57->C[14] &= 0xe;
    }
}
