#include <stdio.h>
#include <string.h>

#include "cpu57.h"
#include "state57.h"
#include "support57.h"

static char *get_aos(ti57_state_t *s, char *str)
{
    char stack[45];
    int k = 0;

    ti57_get_aos_stack(s, stack);
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
            reg = &s->X[c - '0'];
            break;
        case 'X':
            reg = ti57_get_regX(s);
            break;
        }
        if (reg) {
            ti57_user_reg_to_str(reg, ti57_is_sci(s), ti57_get_fix(s), part);
        } else if (c == 'd') {
            char display[25];
            ti57_get_display(s, display);
            strcpy(part, ti57_trim(display));
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

static char *get_instruction_str(ti57_state_t *s, int step, char *str)
{
    ti57_instruction_t *instruction = ti57_get_instruction(s, step);

    sprintf(str, "%s %s %c",
            instruction->inv ? "-" : " ",
            ti57_get_keyname(instruction->key),
            (instruction->d >= 0) ? '0' + instruction->d : ' ');
    return str;
}

static void print_state(ti57_state_t *s)
{
    static char *MODES[] = {"EVAL", "LRN", "RUN"};
    static char *TRIGS[] = {"DEG", "RAD", "GRAD"};
    char str[1000];

    printf("INTERNAL STATE\n");
    printf("  A  = %s\n", ti57_reg_to_str(s->A, str));
    printf("  B  = %s\n", ti57_reg_to_str(s->B, str));
    printf("  C  = %s\n", ti57_reg_to_str(s->C, str));
    printf("  D  = %s\n", ti57_reg_to_str(s->D, str));
    printf("\n");

    for (int i = 0; i < 8; i++)
        printf("  X%d = %s\n", i, ti57_reg_to_str(s->X[i], str));
    printf("\n");
    for (int i = 0; i < 8; i++)
        printf("  Y%d = %s\n", i, ti57_reg_to_str(s->Y[i], str));
    printf("\n");

    printf("  R5=x%02x   RAB=%d\n", s->R5, s->RAB);
    printf("  COND=%d   hex=%d\n", s->COND, s->is_hex);
    printf("  pc=x%03x  stack=[x%03x, x%03x, x%03x]\n",
           s->pc, s->stack[0], s->stack[1], s->stack[2]);
    char disp[25];

    printf("\nMODES\n  %s %s Fix=%d\n",
           MODES[ti57_get_mode(s)], TRIGS[ti57_get_trig(s)], ti57_get_fix(s));

    printf("\nFLAGS\n  2nd[%s] Inv[%s] Sci[%s] Err[%s] NumEdit[%s]\n",
           ti57_is_2nd(s) ? "x" : " ",
           ti57_is_inv(s) ? "x" : " ",
           ti57_is_sci(s) ? "x" : " ",
           ti57_is_error(s) ? "x" : " ",
           ti57_is_number_edit(s) ? "x" : " ");

    printf("\nREGISTERS\n");
    printf("  X  = %s\n",
           ti57_user_reg_to_str(ti57_get_regX(s), false, 9, str));
    printf("  T  = %s\n",
           ti57_user_reg_to_str(ti57_get_regT(s), false, 9, str));
    for (int i = 0; i <= 7; i++) {
        printf("  R%d = %s\n", i,
               ti57_user_reg_to_str(ti57_get_reg(s, i), false, 9, str));
    }

    printf("\nAOS\n");
    printf("  aos_stack = %s\n", ti57_get_aos_stack(s, str));
    printf("  aos = %s\n", get_aos(s, str));

    int last_step = 49;
    while (last_step >= 0 && ti57_get_instruction(s, last_step)->key == 0)
        last_step -= 1;

    printf("\nPROGRAM (%d steps)\n", last_step + 1);
    for (int i = 0; i <= last_step; i++)
        printf("  %02d %s\n", i, get_instruction_str(s, i, str));
    printf("  pc=%d\n", ti57_get_pc(s));

    printf("\nDISP = [%s]\n", ti57_get_display(s, disp));
}

static void burst_until_idle(ti57_state_t *s)
{
   for ( ; ; ) {
       ti57_activity_t activity = ti57_get_activity(s);
       if (activity == TI57_POLL || activity == TI57_BLINK) {
           return;
       }
       ti57_next(s);
   }
}

static void run(ti57_state_t *s, ti57_key_t *keys, int n)
{
    // Init.
    burst_until_idle(s);

    for (int i = 0; i < n; i++) {
        // Key Press.
        ti57_key_press(s, keys[i] / 10, keys[i] % 10);
        burst_until_idle(s);
        // Key Release.
        ti57_key_release(s);
        burst_until_idle(s);
    }
}

int main(void)
{
    ti57_key_t keys[] =
        {10, 52, 13, 70, 10, 60, 70};  // program: sqrt(5)
        // {2, 2, 2, 2, 2, 2, 3};  // ln(ln(...(ln(0))...)).
        // {61, 64, 62, 44, 63, 24, 51, 74};  // 1 + 2 * 3 ^ 4 =
        // {52, 21, 52};  // 5 STO 5
    ti57_state_t s;

    ti57_init(&s);

    run(&s, keys, sizeof(keys)/sizeof(ti57_key_t));
    print_state(&s);
}
