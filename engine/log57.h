#ifndef log57_h
#define log57_h

#include <stdbool.h>

#include "key57.h"

#define LOG57_MAX_ENTRY_COUNT 1000

/**
 * Logging API.
 */

/** The different types of log entries. */
typedef enum log57_type_e {
    LOG57_NUMBER_IN,   // A number entered by the user, may be pending.
    LOG57_PENDING_OP,  // A pending operation such as "STO _".
    LOG57_OP,          // An operation such as "STO 2" or "SIN".
    LOG57_OP_RESULT,   // The result of an operation.
    LOG57_RUN_RESULT,  // The result of a program run.
    LOG57_PAUSE,       // The number on the display, while on Pause.
} log57_type_t;

typedef struct log57_op_s {
    bool inv;
    key57_t key;
    signed char d;
} log57_op_t;

/** A log entry. */
typedef struct log57_entry_s {
    char message[16];
    log57_type_t type;
} log57_entry_t;

/** All the log data. */
typedef struct log57_s {
    log57_entry_t entries[LOG57_MAX_ENTRY_COUNT];
    long logged_count;  // Number of logged entries since reset, can be > LOG57_MAX_ENTRY_COUNT.
    char current_op[16];
} log57_t;

/** Resets the log, setting the logged_count to 0. */
void log57_reset(log57_t *log);

/** Logs a message of a given type. */
void log57_log_display(log57_t *log, char *display, log57_type_t type);

void log57_log_op(log57_t *log, log57_op_t *op, log57_type_t type);

/** Returns the number of logged entries since reset. Can be > LOG57_MAX_ENTRY_COUNT. */
long log57_get_logged_count(log57_t *log);

/**
 * A given log entry.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
log57_entry_t *log57_get_entry(log57_t *log, long index);

void log57_clear_current_op(log57_t *log);

/**
 * A given log message.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
char *log57_get_message(log57_entry_t *entry);

#endif /* log57_h */