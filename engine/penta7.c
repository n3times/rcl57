#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "penta7.h"
#include "support57.h"

static double get_goal_speed(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;
    ti57_activity_t activity = ti57_get_activity(ti57);

    switch(ti57_get_mode(ti57)) {
    case TI57_EVAL:
    case TI57_LRN:
        switch (activity) {
        case TI57_POLL:
            return 0;
        case TI57_BLINK:
            return 1;
        default:
            return -1;
        }
    case TI57_RUN:
        if (ti57_is_stopping(ti57) &&
            penta7->options & PENTA7_FAST_STOP_WHEN_RUNNING_FLAG) {
            // This solves an issue with the original TI-57 where stopping
            // execution on 'Pause' takes up to 1 second in RUN mode.
            return -1;
        } else if (ti57_is_trace(ti57) || activity == TI57_PAUSE) {
            if (penta7->options & PENTA7_FASTER_PAUSE_FLAG) {
                // We find the actual TI-57 a bit sluggish here, so we go 2x.
                return 2;
            } else {
                return 1;
            }
        }
        return -1;
    }
}

static char *get_lrn_display(penta7_t *penta7)
{
    static char str[100];
    ti57_t *ti57 = &penta7->ti57;
    int pc = ti57_get_pc(ti57);
    bool pending = ti57->C[14] & 0x1;

    if (pc == 0 && !pending)
        return "  LRN MODE  ";

    if (!pending  && !penta7->at_end_program)
        pc -= 1;

    ti57_instruction_t *ins = ti57_get_instruction(ti57, pc);

    sprintf(str,
            "  %02d %s%s ",
            pc, ins->inv ? "!" : " ", ti57_get_keyname(ins->key));
    if (ins->d >= 0)
        sprintf(str + strlen(str), "%d ", ins->d);
    else if (pending)
        sprintf(str + strlen(str), "_ ");
    else
        sprintf(str + strlen(str), "  ");
    return str;
}

static void clear_(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    ti57->C[14] &= 0xe;
}

static void clear_2nd(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    ti57->C[14] &= 0x7;
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
    ti57_t *ti57 = &penta7->ti57;

    if (penta7->at_end_program) {
        penta7->at_end_program = false;
    } else if (ti57_is_instruction_edit(ti57)) {
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
    } else if (ti57_is_instruction_edit(ti57)) {
        clear_(penta7);
        key_del(penta7);
    } else if (ti57_get_pc(ti57) > 0) {
        key_bst(penta7);
        key_del(penta7);
    }
}

static void ins(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    if (!ti57_is_instruction_edit(ti57) && !penta7->at_end_program) {
        key_ins(penta7);
    }
}

static void key_press_in_lrn(penta7_t *penta7, int row, int col)
{
    ti57_t *ti57 = &penta7->ti57;
    bool is_2nd, is_inv;

    if (row == 0 && col == 0) {                      // 2ND
        return ti57_key_press(&penta7->ti57, 0, 0);
    } else if (row == 0 && col == 1) {               // INV
        return ti57_key_press(&penta7->ti57, 0, 1);
    }

    is_2nd = ti57_is_2nd(ti57);
    is_inv = ti57_is_inv(ti57);
    clear_2nd(penta7);

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

    if (penta7->at_end_program) {
        return;
    }
    ins(penta7);
    if (is_inv) {
        ti57->B[15] |= 0x4;
    }
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

    do {
        int n = ti57_next(&penta7->ti57);
        double current_speed = get_goal_speed(penta7);
        if (current_speed < 0) {
            max_cycles -= n;
        } else if (current_speed == 0) {
            max_cycles = 0;
        } else {
            max_cycles -= n * speedup / current_speed;
        }
    } while (max_cycles > 0);
}

void penta7_key_press(penta7_t *penta7, int row, int col)
{
    ti57_t *ti57 = &penta7->ti57;

    if (ti57_get_pc(ti57) != 49) {
        penta7->at_end_program = false;
    }

    if (ti57_get_mode(ti57) == TI57_LRN &&
        penta7->options & PENTA7_IMPROVED_LRN_MODE_FLAG) {
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

    if (ti57_get_mode(ti57) == TI57_LRN &&
        penta7->options & PENTA7_IMPROVED_LRN_MODE_FLAG) {
        return get_lrn_display(penta7);
    }

    if (ti57_get_mode(ti57) == TI57_RUN &&
        penta7->options & PENTA7_SHOW_INDICATOR_WHEN_RUNNING_FLAG &&
        get_goal_speed(penta7) < 0) {
        return "[           ";
    }

    bool blinking_blank = ti57_is_error(ti57) && ti57->B[3] == 9;

    if (!blinking_blank &&
        penta7->options & PENTA7_DISPLAY_ARITHMETIC_OPERATORS_FLAG &&
        (ti57_get_mode(ti57) == TI57_EVAL || ti57_is_trace(ti57))) {
        char *stack = ti57_get_aos_stack(ti57);
        char top = stack[strlen(stack) - 1];

        if (top == '+') {
            return "        +   ";
        } else if (top == 'x') {
            return "        x   ";
        } else if (top == '^') {
            return "      X^Y   ";
        } else if (top == 'v') {
            return "     !X^Y   ";
        } else if (top == '-') {
            return "        -   ";
        } else if (top == '/') {
            return "        /   ";
        }

        int len = 0;
        for (int i = (int)strlen(stack) - 1; i >= 0; i--) {
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

void penta7_set_options(penta7_t *penta7, int options) {
    penta7->options = options;
}
