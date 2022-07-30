#include "prog57.h"

#include <string.h>

#include "utils57.h"

#define NAME_HEADER  "@!# name"
#define HELP_HEADER  "@!# help"
#define STATE_HEADER "@!# state"

static bool find_next_section(const char *str, char *section_title_out, char *section_out) {
    char *start = strstr(str, "@!# ");
    if (start == NULL) return false;
    char *end = strchr(start, '\n');
    if (end == NULL) {
        end = strchr(start, '\0');
    }
    memcpy(section_title_out, start, end - start);
    section_title_out[end - start] = '\0';
    start = end + 1;
    end = strstr(start, "@!# ");
    if (end == NULL) {
        end = strchr(start, '\0') + 1;
    }
    end -= 1;
    memcpy(section_out, start, end - start);
    section_out[end - start] = '\0';
    return true;
}

static void append_line(char **text_out, char *str) {
    strcpy(*text_out, str);
    *text_out += strlen(str);
    strcpy(*text_out, "\n");
    *text_out += strlen("\n");
}

static int hex(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    else if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    else if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    else return 0;
}

bool prog57_from_text(prog57_t *program, const char *text_in) {
    memset(program, '\0', sizeof(prog57_t));
    char title[100];
    char section[5000];
    bool found_name = false;
    while (find_next_section(text_in, title, section)) {
        utils57_trim(title);
        utils57_trim(section);

        if (!strcmp(title, NAME_HEADER)) {
            strncpy(program->name, section, sizeof(program->name) - 1);
            found_name = true;
        } else if (!strcmp(title, HELP_HEADER)) {
            strncpy(program->help, section, sizeof(program->help) - 1);
        } else if (!strcmp(title, STATE_HEADER)) {
            for (int i = 0; i < 16; i++) {
                for (int j = 0; j < 16; j++) {
                    program->state[i][j] = hex(section[i * 17 +  j]);
                }
            }
        }
        text_in += strlen(title) + strlen(section) + 2;
    }
    return found_name;
}

char *prog57_to_text(prog57_t *program) {
    static char text[5500];
    char *text_out = text;
    append_line(&text_out, NAME_HEADER);
    append_line(&text_out, program->name);
    append_line(&text_out, HELP_HEADER);
    append_line(&text_out, program->help);
    append_line(&text_out, STATE_HEADER);
    for (int i = 0; i < 16; i++) {
        static char digits[] = "0123456789ABCDEF";
        char str[17];

        for (int j = 0; j < 16; j++) {
            str[j] = digits[program->state[i][j]];
        }
        str[16] = 0;
        append_line(&text_out, str);
    }
    return text;
}

void prog57_set_steps_from_memory(prog57_t *program, rcl57_t *rcl57) {
    memcpy(program->state + 8, rcl57->ti57.Y, 6 * sizeof(ti57_reg_t));
    program->state[14][14] = rcl57->ti57.Y[6][14];
    program->state[14][15] = rcl57->ti57.Y[6][15];
    program->state[15][14] = rcl57->ti57.Y[7][14];
    program->state[15][15] = rcl57->ti57.Y[7][15];
}

void prog57_set_registers_from_memory(prog57_t *program, rcl57_t *rcl57) {
    memcpy(program->state +  5, rcl57->ti57.X + 5, 14 * sizeof(unsigned char));
    memcpy(program->state +  6, rcl57->ti57.X + 6, 14 * sizeof(unsigned char));
    memcpy(program->state +  7, rcl57->ti57.X + 7, 14 * sizeof(unsigned char));
    memcpy(program->state + 14, rcl57->ti57.Y + 6, 14 * sizeof(unsigned char));
    memcpy(program->state + 15, rcl57->ti57.Y + 7, 14 * sizeof(unsigned char));
    memcpy(program->state +  3, rcl57->ti57.X + 3, 14 * sizeof(unsigned char));
    memcpy(program->state +  2, rcl57->ti57.X + 2, 14 * sizeof(unsigned char));
    memcpy(program->state +  4, rcl57->ti57.X + 4, 14 * sizeof(unsigned char));
}

void prog57_load_steps_into_memory(prog57_t *program, rcl57_t *rcl57) {
    ti57_t *ti57 = &rcl57->ti57;

    // Undo '2nd' if necessary.
    if (ti57_is_2nd(ti57)) {
        ti57_key_press(ti57, 1, 1);
        utils57_burst_until_idle(ti57);
        ti57_key_release(ti57);
        utils57_burst_until_idle(ti57);
    }

    // Stop if running.
    if (ti57_get_mode(ti57) == TI57_RUN) {
        // Press R/S.
        ti57_key_press(ti57, 8, 1);
        utils57_burst_until_idle(ti57);
        ti57_key_release(ti57);
        utils57_burst_until_idle(ti57);
    }

    // Get out of LRN mode.
    if (ti57_get_mode(ti57) == TI57_LRN) {
        // Press LRN.
        ti57_key_press(ti57, 2, 1);
        utils57_burst_until_idle(ti57);
        ti57_key_release(ti57);
        utils57_burst_until_idle(ti57);
    }

    memcpy(rcl57->ti57.Y, program->state + 8, 6 * sizeof(ti57_reg_t));
    rcl57->ti57.Y[6][14] = program->state[14][14];
    rcl57->ti57.Y[6][15] = program->state[14][15];
    rcl57->ti57.Y[7][14] = program->state[15][14];
    rcl57->ti57.Y[7][15] = program->state[15][15];
}

void prog57_load_registers_into_memory(prog57_t *program, rcl57_t *rcl57) {
    memcpy(rcl57->ti57.X + 5, program->state +  5, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.X + 6, program->state +  6, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.X + 7, program->state +  7, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.Y + 6, program->state + 14, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.Y + 7, program->state + 15, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.X + 3, program->state +  3, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.X + 2, program->state +  2, 14 * sizeof(unsigned char));
    memcpy(rcl57->ti57.X + 4, program->state +  4, 14 * sizeof(unsigned char));
}

char *prog57_get_name(prog57_t *program) {
    return program->name;
}

void prog57_set_name(prog57_t *program, const char * const name) {
    int size = sizeof(program->name);
    strncpy(program->name, name, size - 1);
    program->name[size - 1] = '\0';
}

char *prog57_get_help(prog57_t *program) {
    return program->help;
}

void prog57_set_help(prog57_t *program, const char * const help) {
    strcpy(program->help, help);
}

bool prog57_has_same_steps_as_state(prog57_t *program, rcl57_t *rcl57) {
    return memcmp(rcl57->ti57.Y, program->state + 8, 6 * sizeof(ti57_reg_t)) == 0 &&
           rcl57->ti57.Y[6][14] == program->state[14][14] &&
           rcl57->ti57.Y[6][15] == program->state[14][15] &&
           rcl57->ti57.Y[7][14] == program->state[15][14] &&
           rcl57->ti57.Y[7][15] == program->state[15][15];
}

bool prog57_has_same_registers_as_state(prog57_t *program, rcl57_t *rcl57) {
    return memcmp(rcl57->ti57.X + 5, program->state +  5, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.X + 6, program->state +  6, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.X + 7, program->state +  7, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.Y + 6, program->state + 14, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.Y + 7, program->state + 15, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.X + 3, program->state +  3, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.X + 2, program->state +  2, 14 * sizeof(unsigned char)) == 0 &&
           memcmp(rcl57->ti57.X + 4, program->state +  4, 14 * sizeof(unsigned char)) == 0;
}
