#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "penta7.h"
#include "support57.h"

static char *get_lrn_display(ti57_t *ti57)
{
    static char str[100];
    int step = ti57_get_pc(ti57);
    ti57_instruction_t *ins = ti57_get_instruction(ti57, step);

    sprintf(str,
            "  %02d %s%3s  ",
            step, ins->inv ? "!" : " ", ti57_get_keyname(ins->key));
    if (ins->d >= 0)
        sprintf(str + 10, "%d ", ins->d);
    else if (ti57->C[14] & 0x1)
        sprintf(str + 10, "_ ");
    else
        sprintf(str + 10, "  ");
    return str;
}

void penta7_init(penta7_t *penta7)
{
    ti57_init(&penta7->ti57);
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
    ti57_key_press(&penta7->ti57, row, col);
}

void penta7_key_release(penta7_t *penta7)
{
    ti57_key_release(&penta7->ti57);
}

char *penta7_get_display(penta7_t *penta7)
{
    ti57_t *ti57 = &penta7->ti57;

    if (ti57_get_mode(ti57) == TI57_RUN) {
        if (ti57_get_speed(ti57) == TI57_FAST) {
            return "[           ";
        }
    } else if (ti57_get_mode(ti57) == TI57_LRN) {
        return get_lrn_display(ti57);
    } else if (ti57_get_mode(ti57) == TI57_EVAL) {
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
