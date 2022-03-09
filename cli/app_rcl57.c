#include <stdio.h>
#include <string.h>

#include "rcl57.h"
#include "state57.h"
#include "support57.h"

static int digit_to_key_map[] = {82, 72, 73, 74, 62, 63, 64, 52, 53, 54};

static void run(ti57_t *ti57, int *keys, int n)
{
    // Init.
    burst_until_idle(ti57);

    for (int i = 0; i < n; i++) {
        int key = keys[i] <= 9 ? digit_to_key_map[keys[i]] : keys[i];

        // Key Press.
        ti57_key_press(ti57, key / 10, key % 10);
        burst_until_busy(ti57);
        // Key Release.
        if (ti57->mode != TI57_LRN && key == 81) {  // R/S
            burst_until_idle(ti57);  // Waiting for key release
            ti57_key_release(ti57);
            burst_until_busy(ti57);  // Start running
            burst_until_idle(ti57);  // Waiting for key press after program run
        } else {
            ti57_key_release(ti57);
            burst_until_idle(ti57);
        }
    }
}

int main(void)
{
    int keys[] =
        {21, 5, 24, 81, 21, 71, 81};  // program: sqrt(5)
        // {13, 13, 13, 13, 13, 13, 14};  // ln(ln(...(ln(0))...)).
        // {1, 75, 2, 55, 3, 35, 4, 85};  // 1 + 2 * 3 ^ 4 =
        // {5, 32, 5};  // 5 STO 5
    rcl57_t rcl57;

    rcl57_init(&rcl57);
    run(&rcl57.ti57, keys, sizeof(keys)/sizeof(int));
    printf("\nDISP = [%s]\n", ti57_get_display(&rcl57.ti57));
}
