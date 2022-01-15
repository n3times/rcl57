#include "cpu57.h"
#include "state57.h"

#include <assert.h>
#include <stdio.h>


/*******************************************************************************
 *
 * MODES
 *
 ******************************************************************************/

mode_t get_mode(state_t *s)
{
    if ((s->C[15] & 0x1) != 0) return LRN;
    if ((s->C[15] & 0x8) != 0) return RUN;

    return EVAL;
}

trig_t get_trig(state_t *s)
{
    if ((s->X[4][15] & 0xC) == 0xC) return GRAD;
    if ((s->X[4][15] & 0xC) == 0x4) return RAD;

    return DEG;
}

int get_fix(state_t *s)
{
    return 9 - s->X[4][14];
}


/*******************************************************************************
 *
 * FLAGS
 *
 ******************************************************************************/

bool_t is_2nd(state_t *s)
{
    if (get_mode(s) == RUN) return FALSE;

    return (s->C[14] & 0x8) != 0;
}

bool_t is_inv(state_t *s)
{
    if (get_mode(s) == RUN) return FALSE;

    return (s->B[15] & 0x4) != 0;
}

bool_t is_error(state_t *s)
{
    if (get_mode(s) == RUN) return FALSE;

    return (s->B[15] & 0x2) != 0;
}

bool_t is_sci(state_t *s)
{
    return (s->B[15] & 0x8) != 0;
}

bool_t is_number_edit(state_t *s)
{
    return (s->B[15] & 0x1) != 0;
}


/*******************************************************************************
 *
 * AOS
 *
 ******************************************************************************/

char *get_aos_stack(state_t *s, char *str)
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
        bool_t inv = (s->X[i][13] & 0x4) != 0;
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
        str[k++] = 'C';

    str[k++] = 0;
    return str;
}


/*******************************************************************************
 *
 * USER REGISTERS
 *
 ******************************************************************************/

reg_t *get_reg(state_t *s, int i)
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

reg_t *get_regX(state_t *s)
{
    // TODO: is this correct?
    return &s->C;
}

reg_t *get_regT(state_t *s)
{
    return &s->X[4];
}


/*******************************************************************************
 *
 * USER PROGRAM
 *
 ******************************************************************************/

static instruction_t ALL_INSTRUCTIONS[256];

static void init_instructions()
{
    static bool_t inited = FALSE;

    if (inited) return;

    for (int i = 0; i <= 0xff; i++) {
        instruction_t *instruction = &ALL_INSTRUCTIONS[i];
        if (i < 0x10) {
            // Digits.
            instruction->inv = FALSE;
            instruction->key = i;
            instruction->d = -1;
        } else if (i < 0xb0) {
            // Ops with no parameters.
            instruction->inv = (i & 0x08) != 0;
            instruction->key = (((i & 0x07) + 1) << 4) | (i & 0xf0) >> 4;
            instruction->d = -1;
        } else {
            // Register ops: RCL, PRD, SUM, EXC and STO.
            static key_t keys[] = {0x33, 0x38, 0x34, 0x39, 0x32};
            instruction->inv = (i & 0x08) != 0;
            instruction->key = keys[(i >> 4) - 0xb];
            instruction->d = i & 0x07;
        }
    }

    // LBL, GTO, SBR and FIX.
    static int start_indices[] = {0x27, 0x2f, 0x77, 0x7f};
    static key_t keys[] = {0x86, 0x51, 0x61, 0x48};
    static int offsets[] = {0, -1, 15, 31, -2, 14, 30, -3, 13, 29};
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 10; j++) {
            instruction_t *instruction =
                &ALL_INSTRUCTIONS[start_indices[i] + offsets[j]];
            instruction->inv = FALSE;
            instruction->key = keys[i];
            instruction->d = j;
        }
    }

    inited = TRUE;
}

int get_pc(state_t *s)
{
    return (s->X[5][15] << 4) + s->X[5][14];
}

int get_ret(state_t *s, int i)
{
    assert(0 <= i && i <= 1);

    return (s->X[6 + i][15] << 4) + s->X[6 + i][14];
}

instruction_t *get_instruction(state_t *s, int step)
{
    int i;
    reg_t *reg;

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
