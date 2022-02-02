#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "penta7.h"
#include "support57.h"

static char *get_lrn_display(penta7_t *penta7)
{
    static char str[100];
    ti57_t *ti57 = &penta7->ti57;
    int pc = ti57_get_pc(ti57);
    bool pending = ti57->C[14] & 0x1;

    if (pc == 0 && !pending)
        return "    READY ";

    if (!pending  && !penta7->at_end_program)
        pc -= 1;

    ti57_instruction_t *ins = ti57_get_instruction(ti57, pc);

    sprintf(str,
            "  %02d %s%3s  ",
            pc, ins->inv ? "!" : " ", ti57_get_keyname(ins->key));
    if (ins->d >= 0)
        sprintf(str + 10, "%d ", ins->d);
    else if (pending)
        sprintf(str + 10, "_ ");
    else
        sprintf(str + 10, "  ");
    return str;
}

static bool has_(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    return ti57->C[14] & 0x1;
}

static void clear_(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    ti57->C[14] &= 0xe;
}

static void burst_until_idle(ti57_t *ti57)
{
   for ( ; ; ) {
       ti57_activity_t activity = ti57_get_activity(ti57);
       if (activity == TI57_POLL || activity == TI57_BLINK) {
           return;
       }
       ti57_next(ti57);
   }
}

static void key(penta7_t *penta7, bool sec, int row, int col)
{
    ti57_t *ti57 = &penta7->ti57;

    if (sec) {
        ti57->C[14] |= 0x8;
    } else {
        ti57->C[14] &= 0x7;
    }
    ti57_key_press(ti57, row, col);
    burst_until_idle(ti57);
    ti57_key_release(ti57);
    burst_until_idle(ti57);
}

static void key_lrn(penta7_t *penta7)
{
     key(penta7, false, 1, 0);
}

static void key_sst(penta7_t *penta7)
{
     key(penta7, false, 2, 0);
}

static void key_bst(penta7_t *penta7)
{
     key(penta7, false, 3, 0);
}

static void key_ins(penta7_t *penta7)
{
     key(penta7, true, 2, 1);
}

static void key_del(penta7_t *penta7)
{
     key(penta7, true, 3, 1);
}

static void bst(penta7_t *penta7)
{
    if (penta7->at_end_program) {
        penta7->at_end_program = false;
    } else if (has_(penta7)) {
        clear_(penta7);
    } else {
        key_bst(penta7);
    }
}

static void sst(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    clear_(penta7);
    if (ti57_get_pc(ti57) == 49) {
        penta7->at_end_program = true;
    } else {
        key_sst(penta7);
    }
}

static void del(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    if (penta7->at_end_program) {
        penta7->at_end_program = false;
        key_del(penta7);
    } else if (has_(penta7)) {
        clear_(penta7);
        key_del(penta7);
    } else if (ti57_get_pc(ti57) > 0) {
        key_bst(penta7);
        key_del(penta7);
    }
}

static void ins(penta7_t *penta7)
{
    if (!has_(penta7) && !penta7->at_end_program) {
        key_ins(penta7);
    }
}

static void key_press_in_lrn(penta7_t *penta7, int row, int col)
{
    ti57_t *ti57 = &penta7->ti57;
    bool is_2nd = ti57_is_2nd(ti57);

    if (!is_2nd && row == 3 && col == 0) {           // BST
        return bst(penta7);
    } else if (!is_2nd && row == 2 && col == 0) {    // SST
        return sst(penta7);
    } else if (is_2nd && row == 2 && col == 1) {     // INS
        return ins(penta7);
    } else if (is_2nd && row == 3 && col == 1) {     // DEL
        return del(penta7);
    } else if (!is_2nd && row == 1 && col == 0) {    // LRN
        return key_lrn(penta7);
    } else if (row == 0 && col == 0) {               // 2ND
        return ti57_key_press(&penta7->ti57, 0, 0);
    }

    if (penta7->at_end_program) return;

    key(penta7, is_2nd, row, col);
    if (ti57_get_mode(ti57) == TI57_EVAL) {
        key_lrn(penta7);
        penta7->at_end_program = true;
    }
    return;
}


void penta7_init(penta7_t *penta7)
{
    ti57_init(&penta7->ti57);
    penta7->at_end_program = false;
}

void penta7_advance(penta7_t *penta7, int ms, int speedup)
{
    assert(ms > 0);
    assert(speedup > 0);

    // An actual TI-57 executes 5000 cycles per second (speed 1).
    int max_cycles = 5 * ms * speedup;
    ti57_speed_t current_speed;

    do {
        int n = ti57_next(&penta7->ti57);
        current_speed = ti57_get_speed(&penta7->ti57);
        switch (current_speed) {
        case TI57_FAST:
            max_cycles -= n;
            break;
        case TI57_SLOW:
            max_cycles -= n * speedup;
            break;
        case TI57_IDLE:
            max_cycles = 0;
            break;
        }
    } while (max_cycles > 0);
}

void penta7_key_press(penta7_t *penta7, int row, int col)
{
    ti57_t *ti57 = &penta7->ti57;

    if (ti57_get_pc(ti57) != 49) {
        penta7->at_end_program = false;
    }

    if (ti57_get_mode(ti57) == TI57_LRN) {
        return key_press_in_lrn(penta7, row, col);
    }

    ti57_key_press(&penta7->ti57, row, col);
}

void penta7_key_release(penta7_t *penta7)
{
    ti57_key_release(&penta7->ti57);
}

char *penta7_get_display(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    if (ti57_get_mode(ti57) == TI57_RUN
     && ti57_get_speed(ti57) == TI57_FAST) {
        return "[           ";
    } else if (ti57_get_mode(ti57) == TI57_LRN) {
        return get_lrn_display(penta7);
    } else if (ti57_get_mode(ti57) == TI57_EVAL
            || ti57_is_trace(ti57)) {
        char *stack = ti57_get_aos_stack(ti57);
        char top = stack[strlen(stack) - 1];

        if (top == '+') {
            return "        +   ";
        } else if (top == '*') {
            return "        X   ";
        } else if (top == '^') {
            return "        ^   ";
        } else if (top == '-') {
            return "        -   ";
        } else if (top == '/') {
            return "        /   ";
        }

        int len = 0;
        for (int i = strlen(stack) - 1; i >= 0; i--) {
            char c = stack[i];
            if (c == '(') {
                len += 1;
            } else {
                break;
            }
        }
        if (len > 0) {
            static char str[13];
            for (int i = 0; i < 9; i++) {
                str[i] = (i >=  9 - len) ? '(' : ' ';
            }
            str[9] = ' ';
            str[10] = ' ';
            str[11] = ' ';
            str[12] = 0;
            return str;
        }
    }

    return ti57_get_display(ti57);
}
