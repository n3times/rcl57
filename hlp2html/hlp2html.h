#ifndef _HLP2HTML_H_
#define _HLP2HTML_H_

/**
 * \file hlp2html.h
 *
 * \brief Utility to transform hlp (TI-59 help) files into HTML files.
 *
 * A hlp file is a text file (ASCII) where some tags are used for formatting
 * and to indicate TI-59 specific elements:
 * - bold   => ''...''
 * - italic => '''...'''
 * - For headers, lines start with 1 or 2 '=':
 *   - main level => =
 *   - sublevel   => ==
 * - For lists, lines start with '*', '#' or ':':
 *   - bullets         => *
 *   - numbered        => #
 *   - simply indented => :
 * - TI-59 elements:
 *   - display      => &&...&&
 *   - printed line => @@...@@
 *   - operators    => $$...$$
 * - TI-59 elements written in alternative form (visually lighter):
 *   - display      => &&&...&&&
 *   - printed line => @@@...@@@
 *   - operators    => $$$...$$$
 *
 * The typical usage is as follows:
 *
 * \code
 * hlp2html_t hlp2html; // User does not initialize this structure
 * char html[1000];
 *
 * hlp2html_init(&hlp2html, "help.css", html, sizeof(html));
 * printf("%s", html);
 * while (...) {        // Go through each line in the help file
 *   hlp2html_next(&hlp2html, hlp_line, html, sizeof(html));
 *   printf("%s", html);
 * }
 * hlp2html_done(&hlp2html, html, sizeof(html));
 * printf("%s", html);
 * \endcode
 *
 * \see hlp_ops.h for the list of operators and how they are represented
 * in a hlp file.
 * \see hlp_print.h for the list of characters which cannot be represented
 * in ASCII and how they are mapped from hlp form to HTML form.
 */

#include "hlp2html_internal.h"

typedef struct hlp2html_s hlp2html_t;

/**
 * This should be called before starting the conversion to HTML.
 *
 * \param hlp2html Structure allocated by the caller used for the utility
 * to keep state. This structure is initialized by this function.
 * \param css_path Path to the CSS file where the look and feel is defined.
 * \param html_out Buffer where the HTML will be written too (NULL-terminated)
 * \param out_size Size of the buffer html_out
 */
int hlp2html_init(hlp2html_t * hlp2html, const char * css_path,
                  char * html_out, int out_size);

/**
 * Converts 1 or more lines of a hlp file into lines of HTML.
 *
 * \param hlp2html Structure allocated by the caller used for the utility
 * to keep state.
 * \param hlp_lines The next hlp lines to be converted.
 * \param html_out Buffer where the HTML will be written too (NULL-terminated)
 * \param out_size Size of the buffer html_out
 */
int hlp2html_next(hlp2html_t * hlp2html, const char * hlp_lines,
                  char * html_out, int out_size);

/**
 * This should be called after all lines have been converted.
 *
 * \param hlp2html Structure allocated by the caller used for the utility
 * to keep state.
 * \param html_out Buffer where the HTML will be written too (NULL-terminated)
 * \param out_size Size of the buffer html_out
 */
int hlp2html_done(hlp2html_t * hlp2html,
                  char * html_out, int out_size);
#endif
