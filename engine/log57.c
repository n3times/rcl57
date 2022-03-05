#include "log57.h"

#include <string.h>

void log57_reset(log57_t *log)
{
    memset(log, 0, sizeof(log57_t));
}

void log57_log_message(log57_t *log, char *message, log57_type_t type)
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
        if (log->logged_count) {
            log57_entry_t *last_entry =
                log57_get_entry(log, log->logged_count % LOG57_MAX_ENTRY_COUNT);
            if (last_entry->type == LOG57_PENDING_OP) {
                override = true;
            }
        }
        break;
    case LOG57_PENDING_OP:
    case LOG57_PAUSE:
    case LOG57_RESULT:
        // nothing
        break;
    }

    if (!override) {
        log->logged_count++;
    }
    int index = log->logged_count % LOG57_MAX_ENTRY_COUNT;
    strcpy(log->entries[index].message, message);
    log->entries[index].type = type;
}

long log57_get_logged_count(log57_t *log)
{
    return log->logged_count;
}

log57_entry_t *log57_get_entry(log57_t *log, long index)
{
    return &log->entries[index % LOG57_MAX_ENTRY_COUNT];
}

char *log57_get_message(log57_t *log, long index)
{
    return log->entries[index % LOG57_MAX_ENTRY_COUNT].message;
}
