#include <stdio.h>
#include <string.h>

#include "ti57.h"
#include "state57.h"
#include "support57.h"

static char *get_aos(ti57_t *ti57, char *str)
{
    char *stack;
    int k = 0;

    stack = ti57_get_aos_stack(ti57);
    for (int i = 0; ; i++) {
        ti57_reg_t *reg = 0;
        char part[25];
        char c = stack[i];

        if (c == 0) break;

        switch(c) {
        case '0':
        case '1':
        case '2':
        case '3':
            reg = &ti57->X[c - '0'];
            break;
        case 'X':
            reg = ti57_get_regX(ti57);
            break;
        }
        if (reg) {
            char *user_reg_str = support57_user_reg_to_str(reg,
                                                      ti57_is_sci(ti57),
                                                      ti57_get_fix(ti57));
            strcpy(part, user_reg_str);
        } else if (c == 'd') {
            strcpy(part, support57_trim(ti57_get_display(ti57)));
        } else {
            int j = 0;
            if (c != '(') part[j++] = ' ';
            part[j++] = c;
            if (c != '(') part[j++] = ' ';
            part[j] = 0;
        }
        int len = strlen(part);
        memcpy(str + k, part, len);
        k += len;
    }
    str[k] = 0;
    return str;
}

static char *get_instruction_str(ti57_t *ti57, int step, char *str)
{
    ti57_instruction_t *instruction = ti57_get_instruction(ti57, step);

    sprintf(str, "%s %s %c",
            instruction->inv ? "-" : " ",
            support57_get_keyname(instruction->key),
            (instruction->d >= 0) ? '0' + instruction->d : ' ');
    return str;
}

static void print_state(ti57_t *ti57)
{
    static char *MODES[] = {"EVAL", "LRN", "RUN"};
    static char *TRIGS[] = {"DEG", "RAD", "GRAD"};
    char str[1000];

    printf("INTERNAL STATE\n");
    printf("  A  = %s\n", support57_reg_to_str(ti57->A));
    printf("  B  = %s\n", support57_reg_to_str(ti57->B));
    printf("  C  = %s\n", support57_reg_to_str(ti57->C));
    printf("  D  = %s\n", support57_reg_to_str(ti57->D));
    printf("\n");

    for (int i = 0; i < 8; i++)
        printf("  X%d = %s\n", i, support57_reg_to_str(ti57->X[i]));
    printf("\n");
    for (int i = 0; i < 8; i++)
        printf("  Y%d = %s\n", i, support57_reg_to_str(ti57->Y[i]));
    printf("\n");

    printf("  R5=x%02x   RAB=%d\n", ti57->R5, ti57->RAB);
    printf("  COND=%d   hex=%d\n", ti57->COND, ti57->is_hex);
    printf("  pc=x%03x  stack=[x%03x, x%03x, x%03x]\n",
           ti57->pc, ti57->stack[0], ti57->stack[1], ti57->stack[2]);

    printf("\nMODES\n  %s %s Fix=%d\n",
           MODES[ti57_get_mode(ti57)],
           TRIGS[ti57_get_trig(ti57)],
           ti57_get_fix(ti57));

    printf("\nFLAGS\n  2nd[%s] Inv[%s] Sci[%s] Err[%s] NumEdit[%s]\n",
           ti57_is_2nd(ti57) ? "x" : " ",
           ti57_is_inv(ti57) ? "x" : " ",
           ti57_is_sci(ti57) ? "x" : " ",
           ti57_is_error(ti57) ? "x" : " ",
           ti57_is_number_edit(ti57) ? "x" : " ");

    printf("\nREGISTERS\n");
    printf("  X  = %s\n",
           support57_user_reg_to_str(ti57_get_regX(ti57), false, 9));
    printf("  T  = %s\n",
           support57_user_reg_to_str(ti57_get_regT(ti57), false, 9));
    for (int i = 0; i <= 7; i++) {
        printf("  R%d = %s\n", i,
               support57_user_reg_to_str(ti57_get_reg(ti57, i), false, 9));
    }

    printf("\nAOS\n");
    printf("  aos_stack = %s\n", ti57_get_aos_stack(ti57));
    printf("  aos = %s\n", get_aos(ti57, str));

    int last_step = 49;
    while (last_step >= 0 && ti57_get_instruction(ti57, last_step)->key == 0)
        last_step -= 1;

    printf("\nPROGRAM (%d steps)\n", last_step + 1);
    for (int i = 0; i <= last_step; i++)
        printf("  %02d %s\n", i, get_instruction_str(ti57, i, str));
    printf("  pc=%d\n", ti57_get_pc(ti57));

    printf("\nDISP = [%s]\n", ti57_get_display(ti57));
}

static void run(ti57_t *ti57, ti57_key_t *keys, int n)
{
    // Init.
    burst_until_idle(ti57);

    for (int i = 0; i < n; i++) {
        // Key Press.
        ti57_key_press(ti57, keys[i] / 10, keys[i] % 10);
        burst_until_idle(ti57);
        // Key Release.
        if (ti57->mode != TI57_LRN && keys[i] == 70) {
            // R/S
            burst_until_idle(ti57);  // Waiting for key release
            ti57_key_release(ti57);
            burst_until_busy(ti57);
            burst_until_idle(ti57);  // Waiting for key press after program run
        } else {
            ti57_key_release(ti57);
            burst_until_idle(ti57);
        }
       burst_until_idle(ti57);
    }
}

int main(void)
{
    ti57_key_t keys[] =
        {10, 52, 13, 70, 10, 60, 70};  // program: sqrt(5)
        // {2, 2, 2, 2, 2, 2, 3};  // ln(ln(...(ln(0))...)).
        // {61, 64, 62, 44, 63, 24, 51, 74};  // 1 + 2 * 3 ^ 4 =
        // {52, 21, 52};  // 5 STO 5
    ti57_t ti57;

    ti57_init(&ti57);

    run(&ti57, keys, sizeof(keys)/sizeof(ti57_key_t));
    print_state(&ti57);
}
