#include "log57.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

void log57_reset(log57_t *log)
{
    memset(log, 0, sizeof(log57_t));
}

void log57_log_op(log57_t *log, log57_op_t *op, bool is_pending)
{
    bool override = false;

    if (!is_pending && log->logged_count) {
        if (log57_get_type(log, log->logged_count % LOG57_MAX_ENTRY_COUNT) == LOG57_PENDING_OP) {
            override = true;
        }
    }

    if (!override) {
        log->logged_count += 1;
    }
    int index = log->logged_count % LOG57_MAX_ENTRY_COUNT;
    char suffix[3];
    if (is_pending) {
        suffix[0] = ' ';
        suffix[1] = '_';
        suffix[2] = 0;
    } else if (op->d >= 0) {
        suffix[0] = ' ';
        suffix[1] = '0' + op->d;
        suffix[2] = 0;
    } else {
        suffix[0] = 0;
    }
    sprintf(log->entries[index].message, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_ascii_name(op->key),
            suffix);
    log->entries[index].type = is_pending ? LOG57_PENDING_OP : LOG57_OP;
    sprintf(log->current_op, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_unicode_name(op->key),
            suffix);}

long log57_get_logged_count(log57_t *log)
{
    return log->logged_count;
}

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
    case LOG57_OP_RESULT:
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
 * Returns the message of a given entry.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
char *log57_get_message(log57_t *log, long index)
{
    return log->entries[index % LOG57_MAX_ENTRY_COUNT].message;
}

/**
 * Returns the type of a given entry.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
log57_type_t log57_get_type(log57_t *log, long index)
{
    return log->entries[index % LOG57_MAX_ENTRY_COUNT].type;
}

char *log57_get_current_op(log57_t *log)
{
    return log->current_op;
}

void log57_clear_current_op(log57_t *log)
{
    log->current_op[0] = 0;
}
