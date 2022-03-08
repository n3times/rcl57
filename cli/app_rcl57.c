#include <stdio.h>
#include <string.h>

#include "key57.h"
#include "rcl57.h"
#include "state57.h"
#include "support57.h"

static void run(ti57_t *ti57, key57_t *keys, int n)
{
    // Init.
    burst_until_idle(ti57);

    for (int i = 0; i < n; i++) {
        printf("\n ====> %d\n", keys[i]); 
        // Key Press.
        ti57_key_press(ti57, keys[i] / 10, keys[i] % 10);
        burst_until_busy(ti57);
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
    }
}

int main(void)
{
    key57_t keys[] =
        {10, 52, 13, 70, 10, 60, 70};  // program: sqrt(5)
        // {10, 52, 13, 70, 10, 60, 70};  // program: sqrt(5)
        // {2, 2, 2, 2, 2, 2, 3};  // ln(ln(...(ln(0))...)).
        // {61, 64, 62, 44, 63, 24, 51, 74};  // 1 + 2 * 3 ^ 4 =
        // {52, 21, 52};  // 5 STO 5
    rcl57_t rcl57;

    rcl57_init(&rcl57);
    run(&rcl57.ti57, keys, sizeof(keys)/sizeof(key57_t));
    printf("\nDISP = [%s]\n", ti57_get_display(&rcl57.ti57));
}
