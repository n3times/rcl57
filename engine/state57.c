#include <assert.h>
#include <stdio.h>

#include "ti57.h"
#include "state57.h"

/*******************************************************************************
 *
 * MODES
 *
 ******************************************************************************/

ti57_mode_t ti57_get_mode(ti57_t *ti57)
{
    if ((ti57->C[15] & 0x1) != 0) return TI57_LRN;
    if ((ti57->C[15] & 0x8) != 0) return TI57_RUN;

    return TI57_EVAL;
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

/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

bool ti57_is_2nd(ti57_t *ti57)
{
    if (ti57_get_mode(ti57) == TI57_RUN) return false;
    if (ti57->supress_modifiers) return false;

    return (ti57->C[14] & 0x8) != 0;
}

bool ti57_is_inv(ti57_t *ti57)
{
    if (ti57_get_mode(ti57) == TI57_RUN) return false;
    if (ti57->supress_modifiers) return false;

    return (ti57->B[15] & 0x4) != 0;
}

bool ti57_is_error(ti57_t *ti57)
{
    if (ti57_get_mode(ti57) != TI57_EVAL) return false;

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

bool ti57_is_instruction_edit(ti57_t *ti57)
{
    return (ti57->C[14] & 0x1) != 0;
}

bool ti57_is_trace(ti57_t *ti57)
{
    if (ti57_get_mode(ti57) != TI57_RUN) return false;

    return ti57->key_pressed && (ti57->row == 2) && (ti57->col == 0);
}

bool ti57_is_stopping(ti57_t *ti57)
{
    if (ti57_get_mode(ti57) != TI57_RUN) return false;

    return ti57->key_pressed && (ti57->row == 7) && (ti57->col == 0);
}

static bool is_pc_in(ti57_t *ti57, int lo, int hi, int depth)
{
   if (ti57->pc >= lo && ti57->pc <= hi) return true;

   for (int i = 0; i <= depth; i++) {
       if (ti57->stack[i] >= lo && ti57->stack[i] <= hi)
           return true;
   }
   return false;
}

ti57_activity_t ti57_get_activity(ti57_t *ti57)
{
    if (is_pc_in(ti57, 0x00fd, 0x0105, 1) ||  // 'Ins'
        is_pc_in(ti57, 0x010c, 0x0116, 1)) {  // 'Del'
        return TI57_LONG;
    }

    if (ti57->stack[0] == 0x010a || ti57->stack[1] == 0x010a) {  // 'Pause'
        return TI57_PAUSE;
    }

    if (ti57->key_pressed) {
        if (is_pc_in(ti57, 0x01fc, 0x01fe, -1) ||   // Waiting for 'R/S' release
            is_pc_in(ti57, 0x04a3, 0x04a5, -1)) {   // Waiting for other release
            return TI57_POLL;
        }
    }

    if (!ti57->key_pressed) {
        if (is_pc_in(ti57, 0x04a6, 0x04a9, 0))      // Waiting for key press
            return ti57_is_error(ti57) ? TI57_BLINK : TI57_POLL;
    }

    return TI57_BUSY;
}

/*******************************************************************************
 *
 * AOS
 *
 ******************************************************************************/

char *ti57_get_aos_stack(ti57_t *ti57)
{
    static char str[45];
    int k = 0;
    int num_operands = 0;

    if (ti57->X[0][14] != 0)
        num_operands = ti57->D[15] + 1;

    // Optional initial opening parentheses.
    if (num_operands == 0) {
        int num_parentheses = ti57->X[0][15];
        for (int i = 0; i < num_parentheses; i++)
            str[k++] = '(';
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
        for (int j = 0; j < ti57->X[i][15]; j++)
            str[k++] = '(';
    }

    // Optional last operand.
    if (ti57->B[15] & 0x1)
        str[k++] = 'd';
    else if ((ti57->C[14] & 0x2) == 0)
        str[k++] = 'X';

    str[k++] = 0;
    return str;
}

/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

ti57_reg_t *ti57_get_reg(ti57_t *ti57, int i)
{
    assert(0 <= i && i <= 7);

    switch(i) {
    case 0: return &ti57->X[5];
    case 1: return &ti57->X[6];
    case 2: return &ti57->X[7];
    case 3: return &ti57->Y[6];
    case 4: return &ti57->Y[7];
    case 5: return &ti57->X[3];
    case 6: return &ti57->X[2];
    case 7: return &ti57->X[4];
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

/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

static ti57_instruction_t ALL_INSTRUCTIONS[256];

static void init_instructions()
{
    for (int i = 0; i <= 0xff; i++) {
        ti57_instruction_t *instruction = &ALL_INSTRUCTIONS[i];
        if (i < 0x10) {
            // Digits.
            instruction->inv = false;
            instruction->key = i;
            instruction->d = -1;
        } else if (i < 0xb0) {
            // Ops with no parameters.
            instruction->inv = (i & 0x08) != 0;
            instruction->key = (((i & 0x07) + 1) << 4) | (i & 0xf0) >> 4;
            instruction->d = -1;
        } else {
            // Register ops: RCL, PRD, SUM, EXC and STO.
            static ti57_key_t keys[] = {0x33, 0x38, 0x34, 0x39, 0x32};
            instruction->inv = (i & 0x08) != 0;
            instruction->key = keys[(i >> 4) - 0xb];
            instruction->d = i & 0x07;
        }
    }

    // LBL, GTO, SBR and FIX.
    static int start_indices[] = {0x27, 0x2f, 0x77, 0x7f};
    static ti57_key_t keys[] = {0x86, 0x51, 0x61, 0x48};
    static int offsets[] = {0, -1, 15, 31, -2, 14, 30, -3, 13, 29};
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 10; j++) {
            ti57_instruction_t *instruction =
                &ALL_INSTRUCTIONS[start_indices[i] + offsets[j]];
            instruction->inv = false;
            instruction->key = keys[i];
            instruction->d = j;
        }
    }
}

int ti57_get_pc(ti57_t *ti57)
{
    int pc = (ti57->X[5][15] << 4) + ti57->X[5][14];

    assert((0 <= pc) && (pc <= 50));

    if (pc == 50) pc = 49;
    return pc;
}

int ti57_get_ret(ti57_t *ti57, int i)
{
    assert(0 <= i && i <= 1);

    return (ti57->X[6 + i][15] << 4) + ti57->X[6 + i][14];
}

ti57_instruction_t *ti57_get_instruction(ti57_t *ti57, int step)
{
    int i;
    ti57_reg_t *reg;
    static bool inited = false;

    assert(0 <= step && step <= 49);

    if (!inited) {
        init_instructions();
        inited = true;
    }
    if (step == 49) {
        reg = &ti57->Y[7];
        i = 15;
    } else {
        reg = &ti57->Y[step / 8];
        i = 15 - 2 * (step % 8);
    }
    return &ALL_INSTRUCTIONS[((*reg)[i] << 4) | (*reg)[i-1]];
}
