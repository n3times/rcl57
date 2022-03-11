#include "log57.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

void log57_reset(log57_t *log)
{
    memset(log, 0, sizeof(log57_t));
}

/**
 * Actual logging.
 */

void log57_log_op(log57_t *log, log57_op_t *op, bool is_pending)
{
    bool override = false;
    log57_entry_t *current_log_entry = NULL;

    if (log->logged_count) {
        current_log_entry = &log->entries[log->logged_count % LOG57_MAX_ENTRY_COUNT];
    }

    if (current_log_entry) {
        if (current_log_entry->type == LOG57_PENDING_OP) {
            override = true;
        }
    }

    if (!override) {
        log->logged_count += 1;
        current_log_entry = &log->entries[log->logged_count % LOG57_MAX_ENTRY_COUNT];
    }

    char param[3];
    if (is_pending) {
        param[0] = ' ';
        param[1] = '_';
        param[2] = 0;
    } else if (op->d >= 0) {
        param[0] = ' ';
        param[1] = '0' + op->d;
        param[2] = 0;
    } else {
        param[0] = 0;
    }

    sprintf(current_log_entry->message, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_ascii_name(op->key),
            param);
    current_log_entry->type = is_pending ? LOG57_PENDING_OP : LOG57_OP;
    sprintf(log->current_op, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_unicode_name(op->key),
            param);}

void log57_log_display(log57_t *log, char *display, log57_type_t type)
{
    bool override = false;

    switch(type) {
    case LOG57_NUMBER_IN:
        if (log->logged_count) {
            if (log57_get_type(log, log->logged_count % LOG57_MAX_ENTRY_COUNT) == LOG57_NUMBER_IN) {
                override = true;
            }
        }
        break;
    case LOG57_OP:
    case LOG57_PENDING_OP:
        assert(false);
        break;
    case LOG57_PAUSE:
    case LOG57_RESULT:
    case LOG57_RUN_RESULT:
        // nothing
        break;
    }

    if (!override) {
        log->logged_count++;
    }
    int index = log->logged_count % LOG57_MAX_ENTRY_COUNT;
    strcpy(log->entries[index].message, display);
    log->entries[index].type = type;
}

/**
 * Log retrieval.
 */

long log57_get_logged_count(log57_t *log)
{
    return log->logged_count;
}

char *log57_get_message(log57_t *log, long index)
{
    assert(index >= 1 && index >= log->logged_count - LOG57_MAX_ENTRY_COUNT);
    assert(index <= log->logged_count);

    return log->entries[index % LOG57_MAX_ENTRY_COUNT].message;
}

log57_type_t log57_get_type(log57_t *log, long index)
{
    assert(index >= 1 && index >= log->logged_count - LOG57_MAX_ENTRY_COUNT);
    assert(index <= log->logged_count);

    return log->entries[index % LOG57_MAX_ENTRY_COUNT].type;
}

/**
 * Current operation.
 */

char *log57_get_current_op(log57_t *log)
{
    return log->current_op;
}

void log57_clear_current_op(log57_t *log)
{
    log->current_op[0] = 0;
}
