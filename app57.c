#include "cpu57.h"

#include <stdio.h>
#include <string.h>


static void load_rom(opcode_t *rom)
{
    unsigned char temp[4096];
    FILE *f;

    memset(temp, 0, sizeof(temp));
    f = fopen("ti57.bin", "rb");
    fread(temp, 4096, 1, f);
    fclose(f);
    for (int i = 0; i < 2048; i++) {
        // Little-endian.
        unsigned short left = temp[2*i];
        unsigned short right = temp[2*i + 1];
        rom[i] = left << 8 | right;
    }
}

static char *reg_to_str(reg_t *reg, char *str)
{
    static char digits[] = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
        str[i] = digits[(*reg)[15 - i]];
    str[16] = 0;
    return str;
}

static void print_state(state_t *s)
{
    char str[20];

    printf("A  = %s\n", reg_to_str(&s->A, str));
    printf("B  = %s\n", reg_to_str(&s->B, str));
    printf("C  = %s\n", reg_to_str(&s->C, str));
    printf("D  = %s\n", reg_to_str(&s->D, str));
    printf("\n");

    for (int i = 0; i < 8; i++)
        printf("X%d = %s\n", i, reg_to_str(&s->X[i], str));
    printf("\n");
    for (int i = 0; i < 8; i++)
        printf("Y%d = %s\n", i, reg_to_str(&s->Y[i], str));
    printf("\n");

    printf("R5 = %x, RAB = %d\n", s->R5, s->RAB);
    printf("COND = %d, hex = %d\n", s->COND, s->is_hex);
    printf("pc = %x, stack = (%x, %x, %x)\n",
           s->pc, s->stack[0], s->stack[1], s->stack[2]);
    char disp[25];
    printf("\n");

    printf("DISP = [%s]\n", get_display(s, disp));
}

static void run(state_t *s, opcode_t *ROM, int *keys, int n)
{
    burst(s, 10000, ROM);
    for (int i = 0; i < n; i++) {
        key_press(s, keys[i] / 10, keys[i] % 10);
        burst(s, 10000, ROM);
        key_release(s);
        burst(s, 10000, ROM);
    }
}

int main(void)
{
    int keys[] =
        {10, 52, 13, 70, 10, 60, 70};  // program: sqrt(5)
        // {2, 2, 2, 2, 2, 2, 3};  // ln(ln(...(ln(0))...)).
        // {61, 64, 62, 44, 63, 24, 51, 74};  // 1 + 2 * 3 ^ 4 =
        // {52, 21, 52};  // 5 STO 5
    state_t s;
    opcode_t ROM[2048];

    load_rom(ROM);
    init(&s);

    run(&s, ROM, keys, sizeof(keys)/sizeof(int));
    print_state(&s);
}
