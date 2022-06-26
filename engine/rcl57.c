#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "lrn57.h"
#include "rcl57.h"
#include "utils57.h"

static bool is_post_pause(ti57_t *ti57) {
    long diff = ti57->current_cycle - ti57->last_pause_cycle;
    return diff > 0 && diff <= 500;
}

static bool is_post_eval(ti57_t *ti57) {
    long diff = ti57->current_cycle - ti57->last_eval_cycle;
    return diff > 0 && diff <= 500;
}

// -1 means as fast as possible.
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
            return 1;
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
        } else if (is_post_pause(ti57)) {
            return 1;
        } else if (is_post_eval(ti57)) {
            return 1;
        }
        return -1;
    }
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

    if (ti57_get_program_pc(ti57) != 49) {
        rcl57->at_end_program = false;
    }

    if (ti57->mode == TI57_LRN &&
        rcl57->options & RCL57_HP_LRN_MODE_FLAG) {
        return lrn57_key_press_in_hp_mode(rcl57, row, col);
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
         rcl57->options & RCL57_ALPHA_LRN_MODE_FLAG)) {
        return lrn57_get_display(rcl57);
    }

    if (ti57->mode == TI57_RUN &&
        rcl57->options & RCL57_SHOW_RUN_INDICATOR_FLAG &&
        ti57->activity != TI57_PAUSE &&
        (get_goal_speed(rcl57) < 0 || is_post_pause(ti57) || is_post_eval(ti57))) {
        return "[           ";
    }

    if (ti57->current_cycle - ti57->last_disp_cycle > 250 * rcl57->speedup) {
        static char str[26];
        strcpy(str, "            ");
        return str;
    }

    return utils57_display_to_str(&ti57->dA, &ti57->dB);
}

void rcl57_clear(rcl57_t *rcl57) {
    ti57_init(&rcl57->ti57);
    rcl57->at_end_program = false;
}

int rcl57_get_program_pc(rcl57_t *rcl57) {
    int pc = ti57_get_program_pc(&rcl57->ti57);
    bool op_pending = ti57_is_op_edit_in_lrn(&rcl57->ti57);
    bool is_hp_mode = rcl57->options & RCL57_HP_LRN_MODE_FLAG;

    if (is_hp_mode && !op_pending && !rcl57->at_end_program) {
        return pc - 1;
    }
    return pc == 50 ? 49 : pc;
}
