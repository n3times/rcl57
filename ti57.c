#include <assert.h>
#include <string.h>

#include "ti57.h"
#include "rom57.h"

/** A 13-bit opcode. */
typedef unsigned short ti57_opcode_t;

/******************************************************************************
 *
 *  MASK OPERATIONS
 *
 *  Performed on digits whose indices are between lo and hi.
 *
 ******************************************************************************/

/** Updates R5 with the 2 least significant digits of reg. */
static void update_R5(ti57_reg_t *reg, ti57_t *ti57, int lo, int hi)
{
    ti57->R5 = (*reg)[lo];
    if (hi > lo)
        ti57->R5 += (*reg)[lo + 1] << 4;
}

/** Determines which base to use when doing arithmetic. */
static int get_base(ti57_t *ti57, int lo)
{
    bool flag_digits = lo >= 13;

    return (flag_digits || ti57->is_hex) ? 16 : 10;
}

/** dest = left + right. */
static void add(ti57_reg_t *dest, ti57_reg_t *left, ti57_reg_t *right,
                ti57_t *ti57, int lo, int hi)
{
    ti57_reg_t temp;
    int base = get_base(ti57, lo);
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
        ti57->COND = 1;
    update_R5(dest, ti57, lo, hi);
}

/** dest = left - right. */
static void subtract(ti57_reg_t *dest, ti57_reg_t *left, ti57_reg_t *right,
                     ti57_t *ti57, int lo, int hi)
{
    ti57_reg_t temp;
    int base = get_base(ti57, lo);
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
        ti57->COND = 1;
    update_R5(dest, ti57, lo, hi);
}

/** reg = reg << 1. */
static void left_shift(ti57_reg_t *reg, ti57_t *ti57, int lo, int hi)
{
    for (int i = hi; i > lo; i--) {
        (*reg)[i] = (*reg)[i - 1];
    }
    (*reg)[lo] = 0;

    update_R5(reg, ti57, lo, hi);
}

/** reg = reg << 1. */
static void right_shift(ti57_reg_t *reg, ti57_t *ti57, int lo, int hi)
{
    for (int i = lo; i < hi; i++) {
        (*reg)[i] = (*reg)[i + 1];
    }
    (*reg)[hi] = 0;

    update_R5(reg, ti57, lo, hi);
}

/** left <=> right. */
static void exchange(ti57_reg_t *left, ti57_reg_t *right, ti57_t *ti57,
                     int lo, int hi)
{
    for (int i = lo; i <= hi; i++) {
        unsigned char d = (*left)[i];
        (*left)[i] = (*right)[i];
        (*right)[i] = d;
    }

    update_R5(right, ti57, lo, hi);
}

/** dest = src. */
static void store(ti57_reg_t *dest, ti57_reg_t *src, ti57_t *ti57,
                  int lo, int hi)
{
    for (int i = lo; i <= hi; i++) {
        (*dest)[i] = (*src)[i];
    }

    update_R5(src, ti57, lo, hi);
}

/******************************************************************************
 *
 *  STACK OPERATIONS
 *
 ******************************************************************************/

static void stack_push(ti57_t *ti57, ti57_address_t val)
{
    ti57->stack[2] = ti57->stack[1];
    ti57->stack[1] = ti57->stack[0];
    ti57->stack[0] = val;
}

static ti57_address_t stack_pop(ti57_t *ti57)
{
    ti57_address_t val = ti57->stack[0];
    ti57->stack[0] = ti57->stack[1];
    ti57->stack[1] = ti57->stack[2];
    return val;
}

/******************************************************************************
 *
 *  CPU INSTRUCTIONS
 *
 ******************************************************************************/

/** Branches conditionally. */
static void op_branch(ti57_t *ti57, ti57_opcode_t opcode)
{
    int COND = opcode >> 10 & 0x1;

    if (COND == ti57->COND)
        ti57->pc = (ti57->pc & 0x400) | (opcode & 0x3ff);
    ti57->COND = 0;
}

/** Calls a subroutine unconditionally. */
static void op_call(ti57_t *ti57, ti57_opcode_t opcode)
{
    stack_push(ti57, ti57->pc);
    ti57->pc = opcode & 0x7ff;
    ti57->COND = 0;
}

/** Performs a flag operation. */
static void op_flag(ti57_t *ti57, ti57_opcode_t opcode)
{
    int j = (opcode & 0x00c0) >> 6;  // register
    int d = (opcode & 0x0030) >> 4;  // digit
    int b = (opcode & 0x000c) >> 2;  // bit
    int f = opcode & 0x0003;         // function

    ti57_reg_t *O[] = {&ti57->A, &ti57->B, &ti57->C, &ti57->D};
    unsigned char *digit = (unsigned char *)O[j] + d + 12;

    switch(f) {
    case 0: *digit |= 1 << b; break;
    case 1: *digit &= ~(1 << b); break;
    case 2: if (*digit & (1 << b)) ti57->COND = 1; break;
    case 3: *digit ^= 1 << b; break;
    }
}

/** Performs a miscellaneous operation. */
static void op_misc(ti57_t *ti57, ti57_opcode_t opcode)
{
    int q = (opcode & 0x00f0) >> 4;  // potential operand
    int p = opcode & 0x000f;         // instruction

    switch(p) {
    case 0: memcpy(ti57->A, ti57->Y[ti57->RAB], sizeof(ti57_reg_t)); break;
    case 1: ti57->RAB = q & 0x7; break;
    case 2: ti57->pc = ti57->R5; break;
    case 3: ti57->COND = 0;
            ti57->pc = stack_pop(ti57);
            break;
    case 4: memcpy(ti57->X[ti57->RAB], ti57->A, sizeof(ti57_reg_t)); break;
    case 5: memcpy(ti57->A, ti57->X[ti57->RAB], sizeof(ti57_reg_t)); break;
    case 6: memcpy(ti57->Y[ti57->RAB], ti57->A, sizeof(ti57_reg_t)); break;
    case 7: if (ti57->key_pressed) {
                ti57->R5 = (ti57->col + 1) << 4 | ti57->row;
                ti57->COND = 1;
            }
            memcpy(ti57->dA, ti57->A, sizeof(ti57_reg_t));
            memcpy(ti57->dB, ti57->B, sizeof(ti57_reg_t));
            break;
    case 8: ti57->is_hex = false; break;
    case 9: ti57->is_hex = true; break;
    case 10: ti57->RAB = ti57->R5 & 0x7; break;
    }
}

/**
 * Performs a mask operation, that is only on a subset of the digits of one or
 * more registers.
 */
static void op_mask(ti57_t *ti57, ti57_opcode_t opcode) {
    int m = (opcode & 0x0f00) >> 8;  // mask
    int j = (opcode & 0x00c0) >> 6;  // left operand
    int k = (opcode & 0x0038) >> 3;  // right operand
    int l = (opcode & 0x0006) >> 1;  // destination
    int n = opcode & 0x0001;         // inverse op

    ti57_reg_t *dest, *left, *right, temp;
    ti57_reg_t *O[] = {&ti57->A, &ti57->B, &ti57->C, &ti57->D};

    int lo = -1, hi = -1;

    switch(m) {
    case 0:  lo = 12; hi = 12; break;
    case 1:  lo =  0; hi = 15; break;
    case 2:  lo =  2; hi = 12; break;
    case 3:  lo =  0; hi = 12; break;
    case 4:  lo =  2; hi =  2; break;
    case 5:  lo =  0; hi =  1; break;
    case 6:  break;  // unused
    case 7:  lo =  0; hi = 13; break;
    case 8:  lo = 14; hi = 14; break;
    case 9:  lo = 13; hi = 15; break;
    case 10: lo = 14; hi = 15; break;
    case 11: break;  // unused
    case 12: break;  // flag operation
    case 13: lo = 13; hi = 13; break;
    case 14: break;  // misc operation
    case 15: lo = 15; hi = 15; break;
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
        temp[lo] = ti57->R5 & 0xf;
        right = &temp;
    } else if (k == 7) {
        memset(&temp, 0, sizeof(ti57_reg_t));
        temp[lo] = ti57->R5 & 0xf;
        if (hi > lo) temp[lo + 1] = (ti57->R5 & 0xf0) >> 4;
        right = &temp;
    }

    if (l <= 2) {
        if (k == 5) {
            if (n) {
                right_shift(left, ti57, lo, hi);
            } else {
                left_shift(left, ti57, lo, hi);
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
                subtract(dest, left, right, ti57, lo, hi);
            } else {
                add(dest, left, right, ti57, lo, hi);
            }
        }
    } else if (l == 3) {
        if (n) {
            store(left, right, ti57, lo, hi);
        } else {
            exchange(&(ti57->A), right, ti57, lo, hi);
        }
    }
}

/******************************************************************************
 *
 *  API IMPLEMENTATION
 *
 ******************************************************************************/

void ti57_init(ti57_t *ti57)
{
    memset(ti57, 0, sizeof(ti57_t));
}

int ti57_next(ti57_t *ti57)
{
    ti57_opcode_t opcode = ROM[ti57->pc];

    if (opcode > 0x1fff) return false;

    ti57->pc += 1;

    if ((opcode & 0x1800) == 0x1800)
        op_branch(ti57, opcode);
    else if ((opcode & 0x1800) == 0x1000)
        op_call(ti57, opcode);
    else if ((opcode & 0x1f00) == 0x0e00)
        op_misc(ti57, opcode);
    else if ((opcode & 0x1f00) == 0x0c00)
        op_flag(ti57, opcode);
    else if ((opcode & 0x1000) == 0x0000)
        op_mask(ti57, opcode);

    return ((opcode & 0x0e07) == 0x0e07) ? 32 : 1;
}


void ti57_key_release(ti57_t *ti57)
{
    ///assert(ti57->key_pressed);

    ti57->key_pressed = false;
}

void ti57_key_press(ti57_t *ti57, int row, int col)
{
    ///assert(!ti57->key_pressed);
    assert(0 <= row && row <= 7);
    assert(0 <= col && col <= 4);

    ti57->key_pressed = true;
    ti57->row = row;
    ti57->col = col;
}

char *ti57_get_display(ti57_t *ti57)
{
    static char digits[] = "0123456789AbCdEF";
    static char str[25];
    int k = 0;

    for (int i = 11; i >= 0; i--) {
        char c;
        if (ti57->dB[i] & 0x8)
            c = ' ';
        else if (ti57->dB[i] & 0x1)
            c = '-';
        else
            c = digits[ti57->dA[i]];
        str[k++] = c;
        if (ti57->dB[i] & 0x2)
            str[k++] = '.';
    }
    str[k] = 0;
    return str;
}
