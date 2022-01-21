#include "cpu57.h"

#include <assert.h>
#include <string.h>

/******************************************************************************
 *
 *  MASK OPERATIONS
 *
 *  Performed on digits whose indices are between lo and hi.
 *
 ******************************************************************************/

/**  Updates R5 with the 2 least significant digits of reg. */
static void update_R5(ti57_reg_t *reg, ti57_state_t *s, int lo, int hi)
{
    s->R5 = (*reg)[lo];
    if (hi > lo)
        s->R5 += (*reg)[lo + 1] << 4;
}

/** Determines which base to use when doing arithmetic. */
static int get_base(ti57_state_t *s, int lo)
{
    bool flag_digits = lo >= 13;

    return (flag_digits || s->is_hex) ? 16 : 10;
}

/** dest = left + right. */
static void add(ti57_reg_t *dest, ti57_reg_t *left, ti57_reg_t *right,
                ti57_state_t *s, int lo, int hi)
{
    ti57_reg_t temp;
    int base = get_base(s, lo);
    int carry = 0;

    if (!dest)
        dest = &temp;
    for (int i = lo; i <= hi; i++) {
        (*dest)[i] = (*left)[i] + (*right)[i] + carry;
        if ((*dest)[i] >= base) {
            (*dest)[i] -= base;
            carry = 1;
        } else {
            carry = 0;
        }
    }

    if (carry)
        s->COND = 1;
    update_R5(dest, s, lo, hi);
}

/** dest = left - right. */
static void subtract(ti57_reg_t *dest, ti57_reg_t *left, ti57_reg_t *right,
                     ti57_state_t *s, int lo, int hi)
{
    ti57_reg_t temp;
    int base = get_base(s, lo);
    int borrow = 0;

    if (!dest)
        dest = &temp;
    for (int i = lo; i <= hi; i++) {
        if ((*left)[i] >= (*right)[i] + borrow) {
            (*dest)[i] = (*left)[i] - (*right)[i] - borrow;
            borrow = 0;
        } else {
            (*dest)[i] = base + (*left)[i] - (*right)[i] - borrow;
            borrow = 1;
        }
    }

    if (borrow)
        s->COND = 1;
    update_R5(dest, s, lo, hi);
}

/** reg = reg << 1. */
static void left_shift(ti57_reg_t *reg, ti57_state_t *s, int lo, int hi)
{
    for (int i = hi; i > lo; i--) {
        (*reg)[i] = (*reg)[i - 1];
    }
    (*reg)[lo] = 0;

    update_R5(reg, s, lo, hi);
}

/** reg = reg << 1. */
static void right_shift(ti57_reg_t *reg, ti57_state_t *s, int lo, int hi)
{
    for (int i = lo; i < hi; i++) {
        (*reg)[i] = (*reg)[i + 1];
    }
    (*reg)[hi] = 0;

    update_R5(reg, s, lo, hi);
}

/** left <=> right. */
static void exchange(ti57_reg_t *left, ti57_reg_t *right, ti57_state_t *s,
                     int lo, int hi)
{
    for (int i = lo; i <= hi; i++) {
        unsigned char d = (*left)[i];
        (*left)[i] = (*right)[i];
        (*right)[i] = d;
    }

    update_R5(right, s, lo, hi);
}

/** dest = src. */
static void store(ti57_reg_t *dest, ti57_reg_t *src, ti57_state_t *s,
                  int lo, int hi)
{
    for (int i = lo; i <= hi; i++) {
        (*dest)[i] = (*src)[i];
    }

    update_R5(src, s, lo, hi);
}

/******************************************************************************
 *
 *  STACK OPERATIONS
 *
 ******************************************************************************/

static void stack_push(ti57_state_t *s, ti57_address_t val)
{
    s->stack[2] = s->stack[1];
    s->stack[1] = s->stack[0];
    s->stack[0] = val;
}

static ti57_address_t stack_pop(ti57_state_t *s)
{
    ti57_address_t val = s->stack[0];
    s->stack[0] = s->stack[1];
    s->stack[1] = s->stack[2];
    return val;
}

/******************************************************************************
 *
 *  CPU INSTRUCTIONS
 *
 ******************************************************************************/

/** Branches conditionally. */
static void op_branch(ti57_state_t *s, ti57_opcode_t opcode)
{
    int COND = opcode >> 10 & 0x1;

    if (COND == s->COND)
        s->pc = (s->pc & 0x400) | (opcode & 0x3ff);
    s->COND = 0;
}

/** Calls a subroutine unconditionally. */
static void op_call(ti57_state_t *s, ti57_opcode_t opcode)
{
    stack_push(s, s->pc);
    s->pc = opcode & 0x7ff;
    s->COND = 0;
}

/** Performs a flag operation. */
static void op_flag(ti57_state_t *s, ti57_opcode_t opcode)
{
    int j = (opcode & 0x00c0) >> 6;  // register
    int d = (opcode & 0x0030) >> 4;  // digit
    int b = (opcode & 0x000c) >> 2;  // bit
    int f = opcode & 0x0003;         // function

    ti57_reg_t *O[] = {&s->A, &s->B, &s->C, &s->D};
    unsigned char *digit = (unsigned char *)O[j] + d + 12;

    switch(f) {
    case 0: *digit |= 1 << b; break;
    case 1: *digit &= ~(1 << b); break;
    case 2: if (*digit & (1 << b)) s->COND = 1; break;
    case 3: *digit ^= 1 << b; break;
    }
}

/** Performs a miscellaneous operation. */
static void op_misc(ti57_state_t *s, ti57_opcode_t opcode)
{
    int q = (opcode & 0x00f0) >> 4;  // potential operand
    int p = opcode & 0x000f;         // instruction

    switch(p) {
    case 0: memcpy(s->A, s->Y[s->RAB], sizeof(ti57_reg_t)); break;
    case 1: s->RAB = q & 0x7; break;
    case 2: s->pc = s->R5; break;
    case 3: s->COND = 0;
            s->pc = stack_pop(s);
            break;
    case 4: memcpy(s->X[s->RAB], s->A, sizeof(ti57_reg_t)); break;
    case 5: memcpy(s->A, s->X[s->RAB], sizeof(ti57_reg_t)); break;
    case 6: memcpy(s->Y[s->RAB], s->A, sizeof(ti57_reg_t)); break;
    case 7: if (s->key_pressed) {
                s->R5 = (s->col + 1) << 4 | s->row;
                s->COND = 1;
            }
            memcpy(s->dA, s->A, sizeof(ti57_reg_t));
            memcpy(s->dB, s->B, sizeof(ti57_reg_t));
            break;
    case 8: s->is_hex = false; break;
    case 9: s->is_hex = true; break;
    case 10: s->RAB = s->R5 & 0x7; break;
    }
}

/**
 * Performs a mask operation, that is only on a subset of the digits of one or
 * more registers.
 */
static void op_mask(ti57_state_t *s, ti57_opcode_t opcode) {
    int m = (opcode & 0x0f00) >> 8;  // mask
    int j = (opcode & 0x00c0) >> 6;  // left operand
    int k = (opcode & 0x0038) >> 3;  // right operand
    int l = (opcode & 0x0006) >> 1;  // destination
    int n = opcode & 0x0001;         // inverse op

    ti57_reg_t *dest, *left, *right, temp;
    ti57_reg_t *O[] = {&s->A, &s->B, &s->C, &s->D};

    int lo = -1, hi = -1;

    switch(m) {
    case 0:  lo = 12, hi = 12; break;
    case 1:  lo =  0, hi = 15; break;
    case 2:  lo =  2, hi = 12; break;
    case 3:  lo =  0, hi = 12; break;
    case 4:  lo =  2, hi =  2; break;
    case 5:  lo =  0, hi =  1; break;
    case 6:  break;  // unused
    case 7:  lo =  0, hi = 13; break;
    case 8:  lo = 14, hi = 14; break;
    case 9:  lo = 13, hi = 15; break;
    case 10: lo = 14, hi = 15; break;
    case 11: break;  // unused
    case 12: break;  // flag operation
    case 13: lo = 13, hi = 13; break;
    case 14: break;  // misc operation
    case 15: lo = 15, hi = 15; break;
    }

    if (lo < 0 || hi < 0) return;

    left = O[j];

    if (k < 4) {
        right = O[k];
    } else if (k == 4) {
        memset(&temp, 0, sizeof(ti57_reg_t));
        temp[lo] = 1;
        right = &temp;
    } else if (k == 6) {
        memset(&temp, 0, sizeof(ti57_reg_t));
        temp[lo] = s->R5 & 0xf;
        right = &temp;
    } else if (k == 7) {
        memset(&temp, 0, sizeof(ti57_reg_t));
        temp[lo] = s->R5 & 0xf;
        if (hi > lo) temp[lo + 1] = (s->R5 & 0xf0) >> 4;
        right = &temp;
    }

    if (l <= 2) {
        if (k == 5) {
            if (n) {
                right_shift(left, s, lo, hi);
            } else {
                left_shift(left, s, lo, hi);
            }
        } else {
            if (l == 0) {
                dest = left;
            } else if (l == 1) {
                if (k < 4) dest = right;
            } else if (l == 2) {
                dest = 0;
            }
            if (n) {
                subtract(dest, left, right, s, lo, hi);
            } else {
                add(dest, left, right, s, lo, hi);
            }
        }
    } else if (l == 3) {
        if (n) {
            store(left, right, s, lo, hi);
        } else {
            exchange(&(s->A), right, s, lo, hi);
        }
    }
}

/** Executes the next instruction. */
static bool execute(ti57_state_t *s, ti57_opcode_t opcode)
{
    if (opcode > 0x1fff) return false;

    s->pc += 1;

    if ((opcode & 0x1800) == 0x1800) {
        op_branch(s, opcode);
    } else if ((opcode & 0x1800) == 0x1000) {
        op_call(s, opcode);
    } else if ((opcode & 0x1f00) == 0x0e00) {
        op_misc(s, opcode);
    } else if ((opcode & 0x1f00) == 0x0c00) {
        op_flag(s, opcode);
    } else if ((opcode & 0x1000) == 0x0000){
        op_mask(s, opcode);
    }

    return true;
}

/******************************************************************************
 *
 *  API IMPLEMENTATION
 *
 ******************************************************************************/

void ti57_init(ti57_state_t *s)
{
    memset(s, 0, sizeof(ti57_state_t));
}

void ti57_burst(ti57_state_t *s, int n, ti57_opcode_t *rom)
{
    for (int i = 0; i < n; i++) {
        ti57_opcode_t opcode = rom[s->pc];
        execute(s, opcode);
    }
}

void ti57_key_release(ti57_state_t *s)
{
    assert(s->key_pressed);

    s->key_pressed = false;
}

void ti57_key_press(ti57_state_t *s, int row, int col)
{
    assert(!s->key_pressed);
    assert(0 <= row && row <= 7);
    assert(0 <= col && col <= 4);

    s->key_pressed = true;
    s->row = row;
    s->col = col;
}

char *ti57_get_display(ti57_state_t *s, char *str)
{
    static char digits[] = "0123456789ABCDEF";
    int k = 0;

    for (int i = 11; i >= 0; i--) {
        char c;
        if (s->dB[i] & 0x8)
            c = ' ';
        else if (s->dB[i] & 0x1)
            c = '-';
        else
            c = digits[s->dA[i]];
        str[k++] = c;
        if (s->dB[i] & 0x2)
            str[k++] = '.';
    }
    str[k] = 0;
    return str;
}
