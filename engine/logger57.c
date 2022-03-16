#include "logger57.h"

#include <stdio.h>
#include <string.h>

#include "utils57.h"

static bool has_result(key57_t key)
{
    int row = key >> 4;
    switch(row) {
    case 0:
        return false;
    case 1:
        return key != 0x19;
    case 2:
        return true;
    case 3:
        return key == 0x33 || key == 0x36 || key == 0x38 || key == 0x30;
    case 4:
        return key == 0x42 || key == 0x44 || key == 0x48 || key == 0x49 || key == 0x40;
    case 5:
    case 6:
    case 7:
        return false;
    case 8:
        return true;
    default:
        return false;
    }
}

static void log_display(ti57_t *ti57, log57_type_t type)
{
    char display_str[26];  // 26 = 2 * 12 + 1 ('?') + 1 (end of string).

    // Use A and B instead of dA and dB, in case the display hasn't been flushed.
    strcpy(display_str, utils57_trim(utils57_display_to_str(&ti57->A, &ti57->B)));
    if (ti57_is_error(ti57)) {
        sprintf(display_str + strlen(display_str), "?");
    }
    log57_log_display(&ti57->log, display_str, type);
}

static void log_op(ti57_t *ti57, bool inv, key57_t key, int d, bool pending)
{
    op57_op_t op;

    op.inv = inv;
    op.key = key;
    op.d = d;
    log57_log_op(&ti57->log, &op, pending);
}

// Activity transitions:
// - [ END_SEQ ]  =  BUSY : POLL_RELEASE : POLL_PRESS or POLL_PRESS_BLINK
// - on start:    =  [ END_SEQ ]
// - key press:   =  POLL_PRESS : [ END_SEQ ]
// - SBR 0:       =  POLL_PRESS : [ END_SEQ ]
// - R/S:         =  POLL_PRESS : BUSY : POLL_RS_RELASE : [ END_SEQ ]
void log57_update_after_next(ti57_t *ti57,
                             ti57_activity_t previous_activity,
                             ti57_mode_t previous_mode)
{
    log57_t *log = &ti57->log;
    key57_t current_key;

    if (ti57->mode == TI57_RUN) {
        if (previous_mode == TI57_EVAL) {
            if (log->pending_op_key == KEY57_SBR) {
                current_key = key57_get_key(ti57->row, ti57->col);
                log_op(ti57, false, log->pending_op_key, current_key, false);
                log->pending_op_key = 0;
                // SBR X has been handled. Do not handle it again in TI57_POLL_KEY_RELEASE.
                log->is_key_logged = true;
            }
        } else if (previous_activity != TI57_PAUSE && ti57->activity == TI57_PAUSE) {
            log_display(ti57, LOG57_PAUSE);
        }
        return;
    }

    // Log the end result of running a program.
    if (previous_mode == TI57_RUN && ti57->mode == TI57_EVAL) {
        log_display(ti57, LOG57_RUN_RESULT);
        return;
    }

    // Log R/S, from EVAL mode, a special case with its own activity.
    if (previous_activity == TI57_BUSY && ti57->activity == TI57_POLL_RS_RELEASE) {
        log_op(ti57, false, KEY57_RS, -1, false);
        // R/S has been handled. Do not handle it again in TI57_POLL_KEY_RELEASE.
        log->is_key_logged = true;
        return;
    }

    if (!(previous_activity == TI57_BUSY && ti57->activity == TI57_POLL_RELEASE)) {
        return;
    }

    // From here on, we are only interested in key presses.

    // Do not check for 'is_key_pressed' as the key may already have been released.

    current_key = key57_get_key(ti57->row, ti57->col);

    // This condition holds when the calculator is just turned on, polling for a key
    // release even if no key has been pressed yet.
    if (current_key == KEY57_NONE) {
        return;
    }

    // Don't log "2nd" and "INV" but take note of their state.
    if (current_key == KEY57_2ND) {
        log->is_pending_sec = ti57_is_2nd(ti57);
        return;
    } else if (current_key == KEY57_INV) {
        log->is_pending_inv = ti57_is_inv(ti57);
        return;
    }

    if (ti57->mode == TI57_LRN) {
        log57_clear_current_op(&ti57->log);
        return;
    }

    // Handle key presses in EVAL mode.

    // Cover 'X' in 'SBR X' and 'R/S' cases.
    if (log->is_key_logged) {
        log->is_key_logged = false;
        return;
    }

    if (log->is_pending_sec && current_key > 0x09) {
        current_key += 5;
    }
    log->is_pending_sec = false;

    if (current_key == KEY57_SST) {
        int pc = ti57->step_at_key_press;
        if (pc < 0 || pc > 49) return;
        op57_op_t *ins = ti57_get_op(ti57, pc);
        if (ins->d >= 0) {
            log->pending_op_key = ins->key;
            current_key = ins->d;
        } else {
            current_key = ins->key;
        }
        log->is_pending_inv = ins->inv;
    }

    if (ti57->parse_state == TI57_PARSE_NUMBER_EDIT) {
        // Log "CLR", if number was not being edited.
        if (current_key == KEY57_CLR) {
            if (ti57->log.logged_count &&
                ti57->log.entries[ti57->log.logged_count].type != LOG57_NUMBER_IN) {
                log_op(ti57, false, KEY57_CLR, -1, false);
                log57_clear_current_op(&ti57->log);
            }
        }

        // Log display.
        log_display(ti57, LOG57_NUMBER_IN);
        log->is_pending_inv = false;
    } else if (ti57->parse_state == TI57_PARSE_OP_EDIT) {
        log->pending_op_key = current_key;
        log_op(ti57, log->is_pending_inv, log->pending_op_key, -1, true);
    } else if (ti57->parse_state == TI57_PARSE_DEFAULT) {
        // Print operation.
        int op_key = (log->pending_op_key && current_key <= 0x09) ? log->pending_op_key : current_key;
        if (log->pending_op_key) {
            if (current_key <= 0x9) {
                log_op(ti57, log->is_pending_inv, log->pending_op_key, current_key, false);
            } else {
                log_op(ti57, log->is_pending_inv, log->pending_op_key, -1, false);
                log_op(ti57, log->is_pending_inv, current_key, -1, false);
            }
        } else {
            log_op(ti57, log->is_pending_inv, current_key, -1, false);
        }
        log->is_pending_inv = false;
        log->pending_op_key = 0;

        // Print result.
        if (has_result(op_key) || ti57_is_error(ti57)) {
            log_display(ti57, LOG57_RESULT);
        }
    }
}

