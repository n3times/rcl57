#include "log57.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

void log57_reset(log57_t *log)
{
    memset(log, 0, sizeof(log57_t));
}

void log57_log_op(log57_t *log, log57_op_t *op, log57_type_t type)
{
    bool override = false;

    switch(type) {
    case LOG57_OP:
        if (log->logged_count) {
            log57_entry_t *last_entry =
                log57_get_entry(log, log->logged_count % LOG57_MAX_ENTRY_COUNT);
            if (last_entry->type == LOG57_PENDING_OP) {
                override = true;
            }
        }
        break;
    case LOG57_PENDING_OP:
        break;
    case LOG57_NUMBER_IN:
    case LOG57_PAUSE:
    case LOG57_OP_RESULT:
    case LOG57_RUN_RESULT:
        assert(false);
        break;
    }

    if (!override) {
        log->logged_count++;
    }
    int index = log->logged_count % LOG57_MAX_ENTRY_COUNT;
    char suffix[3];
    if (type == LOG57_PENDING_OP) {
        strcpy(suffix, " _");
    } else if (op->d >= 0) {
        suffix[0] = ' ';
        suffix[1] = '0' + op->d;
        suffix[2] = 0;
    } else {
        suffix[0] = 0;
    }
    sprintf(log->entries[index].message, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_name(op->key),
            suffix);
    log->entries[index].type = type;
    sprintf(log->current_op, "%s%s%s",
            op->inv ? "INV " : "",
            key57_get_name_unicode(op->key),
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
            log57_entry_t *last_entry =
                log57_get_entry(log, log->logged_count % LOG57_MAX_ENTRY_COUNT);
            if (last_entry->type == LOG57_NUMBER_IN) {
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

log57_entry_t *log57_get_entry(log57_t *log, long index)
{
    return &log->entries[index % LOG57_MAX_ENTRY_COUNT];
}


char *log57_get_message(log57_entry_t *entry)
{
    return entry->message;
}

void log57_clear_current_op(log57_t *log)
{
    log->current_op[0] = 0;
}
