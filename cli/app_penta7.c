#include <stdio.h>
#include <string.h>

#include "penta7.h"
#include "state57.h"
#include "support57.h"

static void burst_until_idle(ti57_t *ti57)
{
   for ( ; ; ) {
       ti57_activity_t activity = ti57_get_activity(ti57);
       if (activity == TI57_POLL || activity == TI57_BLINK) {
           return;
       }
       ti57_next(ti57);
   }
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
        ti57_key_release(ti57);
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
    penta7_t penta7;

    penta7_init(&penta7);
    run(&penta7.ti57, keys, sizeof(keys)/sizeof(ti57_key_t));
    printf("\nDISP = [%s]\n", ti57_get_display(&penta7.ti57));
}
