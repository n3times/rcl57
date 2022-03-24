#include "log57.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

static log57_entry_t *get_entry(log57_t *log, long index)
{
    assert(index >= 1 && index >= log->logged_count - LOG57_MAX_ENTRY_COUNT);
    assert(index <= log->logged_count);

    return &log->entries[index % LOG57_MAX_ENTRY_COUNT];
}

void log57_reset(log57_t *log)
{
    memset(log, 0, sizeof(log57_t));
}

/**
 * ACTUAL LOGGING
 */

void log57_log_op(log57_t *log, op57_op_t *op, bool is_pending)
{
    log57_entry_t *entry = NULL;

    log->timestamp += 1;

    // Decide whether to override the last entry.
    if (log->logged_count > 0) {
        entry = get_entry(log, log->logged_count);
        if (entry->type != LOG57_PENDING_OP) {
            log->logged_count += 1;
            entry = get_entry(log, log->logged_count);
        }
    } else {
        log->logged_count = 1;
        entry = get_entry(log, 1);
    }

    // Compute optional parameter.
    char param[3];
    if (is_pending) {
        strcpy(param, " _");
    } else if (op->d >= 0) {
        param[0] = ' ';
        param[1] = '0' + op->d;
        param[2] = 0;
    } else {
        param[0] = 0;
    }

    // Set entry.
    sprintf(entry->message, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_unicode_name(op->key),
            param);
    entry->type = is_pending ? LOG57_PENDING_OP : LOG57_OP;

    // Update current op.
    strcpy(log->current_op, entry->message);
}

void log57_log_display(log57_t *log, char *display, log57_type_t type)
{
    log->timestamp += 1;

    // Decide whether to override the last entry.
    if (! (type == LOG57_NUMBER_IN &&
           log->logged_count > 0 &&
           get_entry(log, log->logged_count)->type == LOG57_NUMBER_IN) ) {
        log->logged_count++;
    }

    // Set entry.
    log57_entry_t *entry = get_entry(log, log->logged_count);
    strcpy(entry->message, display);
    entry->type = type;
}

/**
 * LOG RETRIEVAL
 */

long log57_get_logged_count(log57_t *log)
{
    return log->logged_count;
}

char *log57_get_message(log57_t *log, long index)
{
    return get_entry(log, index)->message;
}

log57_type_t log57_get_type(log57_t *log, long index)
{
    return get_entry(log, index)->type;
}

/**
 * CURRENT OPERATION
 */

char *log57_get_current_op(log57_t *log)
{
    return log->current_op;
}

void log57_clear_current_op(log57_t *log)
{
    log->current_op[0] = 0;
}
