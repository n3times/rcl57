#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "rcl57.h"
#include "utils57.h"

// -1 means as fast as possible.
// 0 means that the emulator could pause.
static double get_goal_speed(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    switch(ti57->mode) {
    case TI57_EVAL:
    case TI57_LRN:
        switch (ti57->activity) {
        case TI57_POLL_PRESS:
        case TI57_POLL_RELEASE:
        case TI57_POLL_RS_RELEASE:
            return -1;
        case TI57_POLL_PRESS_BLINK:
            return 1;
        default:
            return -1;
        }
    case TI57_RUN:
        if (ti57_is_stopping(ti57) &&
            rcl57->options & RCL57_QUICK_STOP_FLAG) {
            return -1;
        } else if (ti57->activity == TI57_PAUSE) {
            if (rcl57->options & RCL57_SHORT_PAUSE_FLAG) {
                return 2;
            } else {
                return 1;
            }
        } else if (ti57_is_trace(ti57)) {
            if (rcl57->options & RCL57_FASTER_TRACE_FLAG) {
                return 2;
            } else {
                return 1;
            }
        }
        return -1;
    }
}

static char *get_lrn_display(rcl57_t *rcl57)
{
    static char str[25];
    ti57_t *ti57 = &rcl57->ti57;
    int pc = ti57_get_pc(ti57);
    bool op_pending = ti57_is_instruction_lrn_edit(ti57);
    bool is_hp_mode = rcl57->options & RCL57_HP_LRN_MODE_FLAG;
    bool is_alphanumeric_mode = rcl57->options & RCL57_ALPHANUMERIC_LRN_MODE_FLAG;
    int dot_count = 0;

    if (pc == 0 && !op_pending && is_hp_mode) {
        return " Lrn        ";
    }

    if (!op_pending  && !rcl57->at_end_program && is_hp_mode) {
        pc -= 1;
    }

    ti57_instruction_t *instruction = ti57_get_instruction(ti57, pc);

    memset(str, ' ', sizeof(str));
    str[sizeof(str) - 1] = 0;

    // Operation.
    int i = (int)strlen(str) - 1;
    if (instruction->d >= 0) {
        str[i] = '0' + instruction->d;
        i -= 2;
    } else if (op_pending) {
        str[i] = is_alphanumeric_mode ? '_' : '0';
        i -= 2;
    }
    if (is_alphanumeric_mode) {
        char *name = key57_get_ascii_name(instruction->key);
        for (int j = (int)strlen(name) - 1; j >= 0; j--) {
            str[i--] = name[j];
            if (str[i + 1] == '.') {
                str[i--] = ' ';
                dot_count += 1;
            }
        }
    } else {
        str[i--] = '0' + instruction->key % 16;
        str[i--] = '0' + instruction->key / 16;
    }
    if (instruction->inv) {
        if (is_alphanumeric_mode) {
            memcpy(str + i - 3, "INV", 3);
        } else {
            str[i] = '-';
        }
    }

    // Step number.
    char s1 = '0' + pc / 10;
    char s2 = '0' + pc % 10;
    int start = 12 - dot_count;
    if (is_hp_mode) {
        str[start] = s1;
        str[start + 1] = s2;
    } else if (is_alphanumeric_mode) {
        str[start + 3] = s1;
        str[start + 4] = s2;
    } else {
        str[start + 4] = s1;
        str[start + 5] = s2;
    }

    return str + start;
}

static void clear_(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    ti57->C[14] &= 0xe;
}

static void clear_2nd(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    ti57->C[14] &= 0x7;
}

static void key(rcl57_t *rcl57, bool sec, int row, int col)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (sec) {
        ti57->C[14] |= 0x8;
    } else {
        ti57->C[14] &= 0x7;
    }
    ti57_key_press(ti57, row, col);
    utils57_burst_until_idle(ti57);
    ti57_key_release(ti57);
    utils57_burst_until_idle(ti57);
}

static void key_lrn(rcl57_t *rcl57)
{
     key(rcl57, false, 2, 1);
}

static void key_sst(rcl57_t *rcl57)
{
     key(rcl57, false, 3, 1);
}

static void key_bst(rcl57_t *rcl57)
{
     key(rcl57, false, 4, 1);
}

static void key_ins(rcl57_t *rcl57)
{
     key(rcl57, true, 3, 2);
}

static void key_del(rcl57_t *rcl57)
{
     key(rcl57, true, 4, 2);
}

static void bst(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (rcl57->at_end_program) {
        rcl57->at_end_program = false;
    } else if (ti57_is_instruction_lrn_edit(ti57)) {
        clear_(rcl57);
    } else {
        key_bst(rcl57);
    }
}

static void sst(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    clear_(rcl57);
    if (ti57_get_pc(ti57) == 49) {
        rcl57->at_end_program = true;
    } else {
        key_sst(rcl57);
    }
}

static void del(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (rcl57->at_end_program) {
        rcl57->at_end_program = false;
        key_del(rcl57);
    } else if (ti57_is_instruction_lrn_edit(ti57)) {
        clear_(rcl57);
        key_del(rcl57);
    } else if (ti57_get_pc(ti57) > 0) {
        key_bst(rcl57);
        key_del(rcl57);
    }
}

static void ins(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (!ti57_is_instruction_lrn_edit(ti57) && !rcl57->at_end_program) {
        key_ins(rcl57);
    }
}

static void key_press_in_lrn(rcl57_t *rcl57, int row, int col)
{
    ti57_t *ti57 = &rcl57->ti57;
    bool is_2nd, is_inv;
    key57_t pressed_key = key57_get_key(row, col);

    if (pressed_key == KEY57_2ND || pressed_key == KEY57_INV) {
        return ti57_key_press(&rcl57->ti57, row, col);
    }

    is_2nd = ti57_is_2nd(ti57);
    is_inv = ti57_is_inv(ti57);
    clear_2nd(rcl57);

    if (!is_2nd && pressed_key == KEY57_BST) {
        return bst(rcl57);
    } else if (!is_2nd && pressed_key == KEY57_SST) {
        return sst(rcl57);
    } else if (is_2nd && pressed_key == KEY57_STO) {
        return ins(rcl57);
    } else if (is_2nd && pressed_key == KEY57_EE) {
        return del(rcl57);
    } else if (!is_2nd && pressed_key == KEY57_LRN) {
        return key_lrn(rcl57);
    }

    if (rcl57->at_end_program) {
        return;
    }
    ins(rcl57);
    if (is_inv) {
        ti57->B[15] |= 0x4;
    }
    key(rcl57, is_2nd, row, col);
    if (ti57->mode == TI57_EVAL) {
        key_lrn(rcl57);
        rcl57->at_end_program = true;
    }
    return;
}


void rcl57_init(rcl57_t *rcl57)
{
    memset(rcl57, 0, sizeof(rcl57_t));
    rcl57->speedup = 1;
}

bool rcl57_advance(rcl57_t *rcl57, int ms)
{
    assert(ms > 0);
    assert(rcl57->speedup > 0);

    ti57_t *ti57 = &rcl57->ti57;

    // An actual TI-57 executes 5000 cycles per second (speed 1).
    int max_cycles = 5 * ms * rcl57->speedup;

    do {
        int n = ti57_next(ti57);
        if (ti57_is_stopping(ti57) &&
            rcl57->options & RCL57_QUICK_STOP_FLAG) {
            utils57_burst_until_idle(ti57);
        }
        double current_speed = get_goal_speed(rcl57);
        if (current_speed == 0) {
            utils57_burst_until_idle(ti57);
            return false;
        }
        if (current_speed < 0) {
            max_cycles -= n;
        } else if (current_speed == 0) {
            max_cycles = 0;
        } else {
            max_cycles -= n * rcl57->speedup / current_speed;
        }
    } while (max_cycles > 0);

    return true;
}

void rcl57_key_press(rcl57_t *rcl57, int row, int col)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (ti57_get_pc(ti57) != 49) {
        rcl57->at_end_program = false;
    }

    if (ti57->mode == TI57_LRN &&
        rcl57->options & RCL57_HP_LRN_MODE_FLAG) {
        return key_press_in_lrn(rcl57, row, col);
    }

    ti57_key_press(&rcl57->ti57, row, col);
}

void rcl57_key_release(rcl57_t *rcl57)
{
    ti57_key_release(&rcl57->ti57);
}

char *rcl57_get_display(rcl57_t *rcl57)
{
    ti57_t *ti57 = &rcl57->ti57;

    if (ti57->mode == TI57_LRN &&
        (rcl57->options & RCL57_HP_LRN_MODE_FLAG ||
         rcl57->options & RCL57_ALPHANUMERIC_LRN_MODE_FLAG)) {
        return get_lrn_display(rcl57);
    }

    if (ti57->mode == TI57_RUN &&
        rcl57->options & RCL57_SHOW_RUN_INDICATOR_FLAG &&
        get_goal_speed(rcl57) < 0) {
        return "[           ";
    }

    bool blinking_blank = ti57_is_error(ti57) && ti57->B[3] == 9;

    if (!blinking_blank &&
        rcl57->options & RCL57_DISPLAY_ARITHMETIC_OPERATORS_FLAG &&
        (ti57->mode == TI57_EVAL || ti57_is_trace(ti57))) {
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

void rcl57_clear(rcl57_t *rcl57) {
    ti57_init(&rcl57->ti57);
    rcl57->at_end_program = false;
}
