/** API for clients that want to implement a TI-57 emulator. */


#define TRUE 1
#define FALSE 0

typedef unsigned char bool_t;

/** A register composed of 16 digits, decimal (0-9) or hexadecimal (0-f). */
typedef unsigned char reg_t[16];

/** An 11-bit long address. */
typedef unsigned short address_t;

/** A 13-bit long opcode. */
typedef unsigned short opcode_t;

/** The state of a TI-57. */
typedef struct state_s {
    reg_t A, B, C, D;      // Operational Registers
    reg_t X[8], Y[8];      // Storage Registers
    unsigned char RAB;     // Register Address Buffer (3-bit)
    unsigned char R5;      // Auxiliary 8-bit Register
    address_t pc;          // Program Counter
    address_t stack[3];    // Subroutine Stack
    bool_t COND;           // Conditional Latch
    bool_t is_hex;         // Arithmetic done in base 16. If false, in base 10.
    bool_t key_pressed;    // A key is being pressed
    int row, col;          // Row and Column of key
    reg_t dA, dB;          // Copy of A and B for display purposes
} state_t;


/** Initializes the state of a TI-57. */
void init(state_t *s);

/** Executes 'n' instructions starting at s->pc. */
void burst(state_t *s, int n, opcode_t *rom);

/** Called when a key is pressed (row in 0..7, col in 0..4.). */
void key_press(state_t *s, int row, int col);

/** Called when a key is released. */
void key_release(state_t *s);

/** Returns the display as a string (str should be at least 25-char long). */
char *get_display(state_t *s, char *str);
