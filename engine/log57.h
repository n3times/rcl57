/**
 * Logging API.
 */

#ifndef log57_h
#define log57_h

#include <stdbool.h>

#include "key57.h"

#define LOG57_MAX_ENTRY_COUNT 1000

/** The different types of log entries. */
typedef enum log57_type_e {
    LOG57_NUMBER_IN,   // A number entered by the user, may be pending.
    LOG57_PENDING_OP,  // A pending operation such as "STO _".
    LOG57_OP,          // An operation such as "STO 2" or "SIN".
    LOG57_RESULT,      // The result of an operation.
    LOG57_RUN_RESULT,  // The result of a program run.
    LOG57_PAUSE,       // The number on the display, while on Pause.
} log57_type_t;

/** An operation. */
typedef struct log57_op_s {
    bool inv;       // Whether it is an inverse operation.
    key57_t key;    // The key that determines the operator.
    signed char d;  // -1 if operator is parameterless or if the operation is pending.
} log57_op_t;

/** A log entry. */
typedef struct log57_entry_s {
    char message[16];
    log57_type_t type;
} log57_entry_t;

/** All the log data. */
typedef struct log57_s {
    // The log data. */
    log57_entry_t entries[LOG57_MAX_ENTRY_COUNT];
    long logged_count;    // Number of logged entries since reset, can be > LOG57_MAX_ENTRY_COUNT.
    char current_op[16];  // The current operation such as "+", "STO _" or "STO 2".

    // Internal state used for parsing.
    key57_t pending_op_key;  // The key such as "STO" before the digit parameter has been entered.
    bool is_pending_sec;     // Whether 2nd is selected. Used to help determine the operation.
    bool is_pending_inv;     // Whether INV is selected. Used to help determine the operation.
    bool is_key_logged;      // Whether the current key has already been logged.
} log57_t;

/** Resets the log, setting the logged_count to 0. */
void log57_reset(log57_t *log);

/**
 * ACTUAL LOGGING
 */

/** Logs a message of a given type. */
void log57_log_display(log57_t *log, char *display, log57_type_t type);

/** Log an operation, possibly pending. */
void log57_log_op(log57_t *log, log57_op_t *op, bool is_pending);

/**
 * LOG RETRIEVAL
 */

/** Returns the number of logged entries since reset. Can be > LOG57_MAX_ENTRY_COUNT. */
long log57_get_logged_count(log57_t *log);

/**
 * Returns the message of a given entry.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
char *log57_get_message(log57_t *log, long index);

/**
 * Returns the type of a given entry.
 *
 * 'index' should be between max(1, logged_count - LOG57_MAX_ENTRY_COUNT + 1) and logged_count.
 */
log57_type_t log57_get_type(log57_t *log, long index);

/**
 * CURRENT OPERATION
 */

/** Gets the last operation in EVAL mode. */
char *log57_get_current_op(log57_t *log);

/** Clears the last operation in EVAL mode. */
void log57_clear_current_op(log57_t *log);

#endif /* log57_h */
