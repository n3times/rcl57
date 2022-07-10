#include "prog57.h"

#include <string.h>

#include "utils57.h"

#define NAME_HEADER  "@!# name"
#define HELP_HEADER  "@!# help"
#define STATE_HEADER "@!# state"

static bool find_next_section(const char *str, char *section_title_out, char *section_out) {
    char *start = strstr(str, "@!# ");
    if (start == NULL) return false;
    char *end = strchr(str, '\n');
    memcpy(section_title_out, start, end - start);
    section_title_out[end - start] = '\0';
    start = end + 1;
    end = strstr(start, "@!# ");
    if (end == NULL) {
        end = strchr(start, '\0');
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

void prog57_from_text(prog57_t *program, const char *text_in) {
    memset(program, '\0', sizeof(prog57_t));
    char title[100];
    char section[5000];
    while (find_next_section(text_in, title, section)) {
        if (!strcmp(title, NAME_HEADER)) {
            strncpy(program->name, section, sizeof(program->name) - 1);
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
        char *str = utils57_reg_to_str(program->state[i]);
        append_line(&text_out, str);
    }
    return text;
}

void prog57_load_state(prog57_t *program_in, rcl57_t *rcl57) {
    ti57_t *ti57 = &rcl57->ti57;

    // Get out of LRN mode.
    if (ti57_get_mode(ti57) == TI57_LRN) {
        // Undo '2nd' if necessary.
        if (ti57_is_2nd(ti57)) {
            ti57_key_press(ti57, 1, 1);
            utils57_burst_until_idle(ti57);
            ti57_key_release(ti57);
            utils57_burst_until_idle(ti57);
        }

        // Press R/S.
        ti57_key_press(ti57, 2, 1);
        utils57_burst_until_idle(ti57);
        ti57_key_release(ti57);
        utils57_burst_until_idle(ti57);
    }

    memcpy(rcl57->ti57.X, program_in->state, 16 * sizeof(ti57_reg_t));
}

void prog57_save_state(prog57_t *program_out, rcl57_t *rcl57) {
    memcpy(program_out->state, rcl57->ti57.X, sizeof(program_out->state));
}

char *prog57_get_name(prog57_t *program) {
    return program->name;
}

void prog57_set_name(prog57_t *program, const char * const name) {
    strcpy(program->name, name);
}

char *prog57_get_help(prog57_t *program) {
    return program->help;
}

void prog57_set_help(prog57_t *program, const char * const help) {
    strcpy(program->help, help);
}
