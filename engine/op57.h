/**
 * Describes an operation such as "+" or "STO 3".
 */

#ifndef op57_h
#define op57_h

/** An operation. */
typedef struct op57_op_s {
    bool inv;       // Whether it is an inverse operation.
    key57_t key;    // The key that determines the operator.
    signed char d;  // -1 if operator is parameterless or if the operation is pending.
} op57_op_t;

#endif /* op57_h */
