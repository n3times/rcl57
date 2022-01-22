#include "cpu57.h"
#include "state57.h"

#include <assert.h>
#include <stdio.h>

/*******************************************************************************
 *
 * MODES
 *
 ******************************************************************************/

ti57_mode_t ti57_get_mode(ti57_state_t *s)
{
    if ((s->C[15] & 0x1) != 0) return TI57_LRN;
    if ((s->C[15] & 0x8) != 0) return TI57_RUN;

    return TI57_EVAL;
}

ti57_trig_t ti57_get_trig(ti57_state_t *s)
{
    if ((s->X[4][15] & 0xC) == 0xC) return TI57_GRAD;
    if ((s->X[4][15] & 0xC) == 0x4) return TI57_RAD;

    return TI57_DEG;
}

int ti57_get_fix(ti57_state_t *s)
{
    return 9 - s->X[4][14];
}

/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

bool ti57_is_2nd(ti57_state_t *s)
{
    if (ti57_get_mode(s) == TI57_RUN) return false;

    return (s->C[14] & 0x8) != 0;
}

bool ti57_is_inv(ti57_state_t *s)
{
    if (ti57_get_mode(s) == TI57_RUN) return false;

    return (s->B[15] & 0x4) != 0;
}

bool ti57_is_error(ti57_state_t *s)
{
    if (ti57_get_mode(s) != TI57_EVAL) return false;

    return (s->B[15] & 0x2) != 0;
}

bool ti57_is_sci(ti57_state_t *s)
{
    return (s->B[15] & 0x8) != 0;
}

bool ti57_is_number_edit(ti57_state_t *s)
{
    return (s->B[15] & 0x1) != 0;
}

bool ti57_is_trace(ti57_state_t *s)
{
    if (ti57_get_mode(s) != TI57_RUN) return false;

    return s->key_pressed && (s->row == 2) && (s->col == 0);
}

bool ti57_is_stopping(ti57_state_t *s)
{
    if (ti57_get_mode(s) != TI57_RUN) return false;

    return s->key_pressed && (s->row == 7) && (s->col == 0);
}

static bool is_pc_in(ti57_state_t *s, int lo, int hi, int depth)
{
   if (s->pc >= lo && s->pc <= hi) return true;

   for (int i = 0; i <= depth; i++) {
       if (s->stack[i] >= lo && s->stack[i] <= hi)
           return true;
   }
   return false;
}

ti57_activity_t ti57_get_activity(ti57_state_t *s)
{
    if (is_pc_in(s, 0x00fd, 0x0105, 1) ||  // 'Ins'
        is_pc_in(s, 0x010c, 0x0116, 1)) {  // 'Del'
        return TI57_LONG;
    }

    if (s->stack[0] == 0x010a || s->stack[1] == 0x010a) {  // 'Pause'
        return TI57_PAUSE;
    }

    if (s->key_pressed) {
        if (is_pc_in(s, 0x01fc, 0x01fe, -1) ||   // Waiting for 'R/S' release 
            is_pc_in(s, 0x04a3, 0x04a5, -1)) {   // Waiting for other release
            return TI57_POLL;
        }
    }

    if (!s->key_pressed) {
        if (is_pc_in(s, 0x04a6, 0x04a9, 0))      // Waiting for key press
            return ti57_is_error(s) ? TI57_BLINK : TI57_POLL;
    }

    return TI57_BUSY;
}

/*******************************************************************************
 *
 * AOS
 *
 ******************************************************************************/

char *ti57_get_aos_stack(ti57_state_t *s, char *str)
{
    int k = 0;
    int num_operands = 0;

    if (s->X[0][14] != 0)
        num_operands = s->D[15] + 1;

    // Optional initial opening parentheses.
    if (num_operands == 0) {
        int num_parentheses = s->X[0][15];
        for (int i = 0; i < num_parentheses; i++)
            str[k++] = '(';
    }

    // List of [operand, operator, parentheses]
    for (int i = 0; i < num_operands; i++) {
        bool inv = (s->X[i][13] & 0x4) != 0;
        str[k++] = '0' + i;
        switch(s->X[i][14]) {
            case 2: str[k++] = inv ? '-' : '+'; break;
            case 4: str[k++] = inv ? '/' : '*'; break;
            case 8: str[k++] = inv ? 'v' : '^'; break;
            default: str[k++] = '?';
        }
        for (int j = 0; j < s->X[i][15]; j++)
            str[k++] = '(';
    }

    // Optional last operand.
    if (s->B[15] & 0x1)
        str[k++] = 'd';
    else if ((s->C[14] & 0x2) == 0)
        str[k++] = 'X';

    str[k++] = 0;
    return str;
}

/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

ti57_reg_t *ti57_get_reg(ti57_state_t *s, int i)
{
    assert(0 <= i && i <= 7);

    switch(i) {
    case 0: return &s->X[5];
    case 1: return &s->X[6];
    case 2: return &s->X[7];
    case 3: return &s->Y[6];
    case 4: return &s->Y[7];
    case 5: return &s->X[3];
    case 6: return &s->X[2];
    case 7: return &s->X[4];
    default: return 0;
    }
}

ti57_reg_t *ti57_get_regX(ti57_state_t *s)
{
    // TODO: is this correct?
    return &s->C;
}

ti57_reg_t *ti57_get_regT(ti57_state_t *s)
{
    return &s->X[4];
}

/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

static ti57_instruction_t ALL_INSTRUCTIONS[256];

static void init_instructions()
{
    static bool inited = false;

    if (inited) return;

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

    inited = true;
}

int ti57_get_pc(ti57_state_t *s)
{
    return (s->X[5][15] << 4) + s->X[5][14];
}

int ti57_get_ret(ti57_state_t *s, int i)
{
    assert(0 <= i && i <= 1);

    return (s->X[6 + i][15] << 4) + s->X[6 + i][14];
}

ti57_instruction_t *ti57_get_instruction(ti57_state_t *s, int step)
{
    int i;
    ti57_reg_t *reg;

    assert(0 <= step && step <= 49);

    init_instructions();
    if (step == 49) {
        reg = &s->Y[7];
        i = 15;
    } else {
        reg = &s->Y[step / 8];
        i = 15 - 2 * (step % 8);
    }
    return &ALL_INSTRUCTIONS[((*reg)[i] << 4) | (*reg)[i-1]];
}
