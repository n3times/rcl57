#include "penta7.h"
#include "support57.h"

void penta7_init(penta7_t *penta7)
{
    ti57_init(&penta7->ti57);
}

penta7_speed_t penta7_advance(penta7_t *penta7)
{
    return (penta7_speed_t) ti57_next(&penta7->ti57);
}

penta7_speed_t penta7_key_press(penta7_t *penta7, int row, int col)
{
    ti57_key_press(&penta7->ti57, row, col);
    return (penta7_speed_t) ti57_get_speed(&penta7->ti57);
}

penta7_speed_t penta7_key_release(penta7_t *penta7)
{
    ti57_key_release(&penta7->ti57);
    return (penta7_speed_t) ti57_get_speed(&penta7->ti57);
}

char *penta7_get_display(penta7_t *penta7)
{
    return ti57_get_display(&penta7->ti57);
}
