#ifndef prog57_h
#define prog57_h

#include "rcl57.h"

typedef struct prog57_s {
    char name[100];
    char help[5000];
    ti57_reg_t state[16];
} prog57_t;

void prog57_from_text(prog57_t *program, const char *text_in);

char *prog57_to_text(prog57_t *program);

void prog57_load_state(prog57_t *program, rcl57_t *rcl57);

void prog57_save_state(prog57_t *program, rcl57_t *rcl57);

char *prog57_get_name(prog57_t *program);

void prog57_set_name(prog57_t *program, const char * const name);

char *prog57_get_help(prog57_t *program);

void prog57_set_help(prog57_t *program, const char * const help);

#endif /* prog57_h */
