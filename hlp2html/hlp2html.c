/**
 * Utility to transform hlp (TI-57 help) files into HTML files.
 */

#include <stdio.h>
#include <string.h>

#include "hlp2html.h"
#include "hlp_ops.h"

/* Tags in hlp files */

#define HLP_BOLD          "''"
#define HLP_ITALIC        "'''"

#define HLP_HEADER        '='

#define HLP_LIST_BULLET   '*'
#define HLP_LIST_NUMBER   '#'
#define HLP_LIST_INDENT   ':'

#define HLP_OPS_STD       "$$"
#define HLP_OPS_LIGHT     "$$$"

#define HLP_DISPLAY_STD   "@@"
#define HLP_DISPLAY_LIGHT "@@@"

/* Corresponding tags in HTML files */

#define HTML_BOLD             "b"
#define HTML_ITALIC           "i"

#define HTML_HEADER_1         "h1"
#define HTML_HEADER_2         "h2"

#define HTML_LIST_BULLET      "ul"
#define HTML_LIST_NUMBER      "ol"
#define HTML_LIST_INDENT      "dl"

#define HTML_LIST_ITEM_BULLET "li"
#define HTML_LIST_ITEM_NUMBER "li"
#define HTML_LIST_ITEM_INDENT "dd"

/* HTML footer and header */

#define HTML_HEADER_FORMAT "<html><head>\n" \
  "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\"></head><body>"

#define HTML_FOOTER "</body></html>"

/* CSS classes used to represent the different elements */

#define CSS_NUMBER         "number"
#define CSS_DISPLAY_STD    "display"
#define CSS_DISPLAY_LIGHT  "display2"

#define CSS_BUTTON_WHITE   "wbutton"
#define CSS_BUTTON_YELLOW  "ybutton"
#define CSS_BUTTON_BROWN   "wbutton"
#define CSS_BUTTON_ABOVE   "bbutton"
#define CSS_BUTTON_ABOVE2  "bbutton2"
#define CSS_BUTTON_VIRTUAL CSS_NUMBER /* No decoration */

#define CSS_OPEN_SPAN(CLASS) "<span class=\"" CLASS "\">"
#define CSS_CLOSE_SPAN       "</span>"

/******************************************************************************
 *                                                                            *
 *                             Utility Methods                                *
 *                                                                            *
 ******************************************************************************/

/**
 * Finds an operator by name as it appears in a hlp file.
 *
 * The operator structure contains information about this operator,
 * notably how to represent it in HTML.
 * Note that this search in case insensitive.
 *
 * \return NULL if there is no such an operator.
 */
static op_t * find_op(const char * op_string)
{
  op_t * op = NULL;
  int i;

  for (i = 0; i < sizeof(ops)/sizeof(ops[0]); i++) {
    if (strcasecmp(ops[i].help_op, op_string) == 0) {
      op = (op_t *) &ops[i];
      break;
    }
  }

  return op;
}

/**
 * Looks for the first occurrence of a string and replaces it, in place,
 * with a new one.
 *
 * \return NULL if no match  Otherwise a pointer to the first character in
 * the new line located after the new_string.
 */
static char * replace(char * line,
                      const char * search_string,
                      const char * new_string)
{
  char * start = NULL;
  char * end   = NULL;

  start = strstr(line, search_string);
  if (start == NULL) goto done;

  memmove(start + strlen(new_string), start + strlen(search_string),
          strlen(start) + 1 - strlen(search_string));

  strncpy(start, new_string, strlen(new_string));

  end = start + strlen(new_string);

done:

  return end;
}

static int is_caption_long(const char * op_string)
{
    char * long_ops[] = {"wrt", "pause", "stf", "iff", "d.ms"};
    int n = sizeof(long_ops) / sizeof(long_ops[0]);
    int i;
    for (i = 0; i < n; i++) {
        if (strcasecmp(op_string, long_ops[i]) == 0) return 1;
    }
    return 0;
}

static void get_html_info_for_op(const char * op_string, int light,
                                 char ** css_class, char ** caption)
{
  op_t * op = find_op(op_string);

  if (op == NULL) {
    *caption = (char *) op_string;
    *css_class = CSS_NUMBER;
  } else {
    *caption = op->html_op;
    if (light) {
      *css_class = CSS_NUMBER;
    } else {
      switch(op->button_type) {
        case BUTTON_WHITE:
          *css_class = (op_string[1] == '\0') && (op_string[0] >=  '0') && (op_string[0] <= '9')
                     ? CSS_NUMBER : CSS_BUTTON_WHITE;
          break;
        case BUTTON_YELLOW:
          /* Only display "2nd" in yellow. Looks better */
          *css_class = strcmp(op_string, "2nd") == 0 ? CSS_BUTTON_YELLOW : CSS_BUTTON_WHITE;
          break;
        case BUTTON_DEFAULT:   *css_class = CSS_BUTTON_BROWN;   break;
        case BUTTON_SECONDARY:   *css_class = is_caption_long(op_string) ? CSS_BUTTON_ABOVE2 : CSS_BUTTON_ABOVE; break;
      }
    }
  }
}

/**
 * Transforms a sequence of operations from hlp format to HTML format.
 *
 * \see hlp_ops.h
 */
static void escape_ops(const char * line, char * escaped_line, int light)
{
  char * c = (char *) line;

  escaped_line[0] = '\0';

  while (1) {
    /* Look for next operator */
    char op[100];
    char escaped_op[100];
    char * op_p = op;
    char * css_class;
    char * caption;
    op[0] = '\0';
    while (*c == ' ') c++;
    while (*c != ' ' && *c != 0) {
      *op_p = *c;
      op_p++;
      c++;
    }
    if (op[0] == '\0') break;
    snprintf(escaped_op, op_p - op + 1, "%s", op);
    *op_p = '\0';
    get_html_info_for_op(op, light, &css_class, &caption);
    sprintf(escaped_op, "<span class=\"%s\">%s%s",
                        css_class, caption, CSS_CLOSE_SPAN);
    strcat(escaped_line, escaped_op);
    if (*c == '\0') break;
    c++;
  }
}

/**
 * Looks for the first matching tags (current tag's) and replaces them, in
 * place, by the corresponding new tags.
 *
 * \return NULL if no match, or a pointer to the first character in the new
 * line located after the new close tag.
 */
static char * replace_matching_tags(char * line,
                                    const char * current_open_tag,
                                    const char * new_open_tag,
                                    const char * current_close_tag,
                                    const char * new_close_tag)
{
  char * start = NULL;
  char * end   = NULL;

  start = strstr(line, current_open_tag);
  if (start == NULL) goto done;

  end = strstr(start + strlen(current_open_tag), current_close_tag);
  if (end == NULL) goto done;

  /* We have matching tags */
  end = replace(start, current_open_tag, new_open_tag);
  end = replace(end, current_close_tag, new_close_tag);

done:

  return end;
}

/**
 * Looks for the first occurrence of an item in bold (''...'') and
 * converts it into HTML.
 *
 * \return NULL if no match, or a pointer to the first character in the new
 * line located after the bold part.
 */
static char * make_bold(char * line)
{
  return replace_matching_tags(line, HLP_BOLD, "<"  HTML_BOLD ">",
                                     HLP_BOLD, "</" HTML_BOLD ">");
}

/**
 * Looks for the first occurrence of an item in italics ('''...''') and
 * converts it into HTML.
 */
static char * make_italic(char * line)
{
  return replace_matching_tags(line, HLP_ITALIC, "<"  HTML_ITALIC ">",
                                     HLP_ITALIC, "</" HTML_ITALIC ">");
}

/**
 * Looks for the first occurrence of a display item (@@...@@ or @@@...@@@)
 * and converts it into HTML.
 */
static char * make_display(char * line)
{
  char * end;

  /* Try first the first style */
  end = replace_matching_tags(line,
            HLP_DISPLAY_LIGHT, CSS_OPEN_SPAN(CSS_DISPLAY_LIGHT),
            HLP_DISPLAY_LIGHT, CSS_CLOSE_SPAN);

  /* If no match, try the second one */
  if (end == NULL) {
    end = replace_matching_tags(line,
            HLP_DISPLAY_STD, CSS_OPEN_SPAN(CSS_DISPLAY_STD),
            HLP_DISPLAY_STD, CSS_CLOSE_SPAN);
  }

  return end;
}

/**
 */
static char * unescape_slashes(char * line)
{
  char * end;

  end = replace_matching_tags(line, "\\$", "$", "\\$", "$");

  if (end == NULL) {
    end = replace_matching_tags(line, "\\@", "@", "\\@", "@");
  }

  if (end == NULL) {
    end = replace_matching_tags(line, "\\&", "&", "\\&", "&");
  }

  if (end == NULL) {
    end = replace_matching_tags(line, "\\'", "'", "\\'", "'");
  }

  return end;
}

/**
 * Looks for the first occurrence of a ops item ($$...$$ or $$$...$$$)
 * and converts it into HTML.
 *
 * A ops item is a sequence of (button) ops which can be seen also
 * as operations/operators, for example "STO 59". We want to render this
 * in HTML form. For example, by representing "STO" as a button and "59"
 * in bold.
 */
static char * make_ops(char * line)
{
  char * start = NULL;
  char * end   = NULL;
  char ops_line[1000];
  char escaped_line[1000];
  int ops_light = 0;

  if ((start = strstr(line, HLP_OPS_LIGHT)) != NULL &&
      (end = strstr(start + 3, HLP_OPS_LIGHT)) != NULL) {
    ops_light = 1;
    start += 3;
  } else if ((start = strstr(line, HLP_OPS_STD)) != NULL &&
            (end = strstr(start + 2, HLP_OPS_STD)) != NULL) {
    ops_light = 0;
    start += 2;
  } else {
    end = NULL;
    goto done;
  }

  strcpy(ops_line, start);
  ops_line[end - start] = '\0';
  escape_ops(ops_line, escaped_line, ops_light);

  replace(start, ops_line, escaped_line);

  if (ops_light) {
    end =  replace_matching_tags(line, HLP_OPS_LIGHT, "",
                                       HLP_OPS_LIGHT, "");
  } else {
    end =  replace_matching_tags(line, HLP_OPS_STD, "",
                                       HLP_OPS_STD, "");
  }

done:

  return end;
}

/**
 */
static int trim_header(char * line)
{
  char * first;
  char * last;
  char * current;
  int type = 0;

  while (type < 2) {
    first = line;
    if (*first != '=') {
      /* Not a header */
      break;
    }

    last = line;
    current = line;
    while (*current != '\0') {
      if (*current != ' ') {
        last = current;
      }
      current++;
    }
    if (*last != '=' || first == last) {
      /* Not a header */
      break;
    }

    replace(last,  "=", "");
    replace(first, "=", "");

    type++;
  }

  return type;
}

/**
 * Converts a help line into an HTML line.
 */
static line_type_t line2html(char * line, char * html)
{
  line_type_t type = LINE_TYPE_OTHER;
  char first = line[0];

  /* Determine type (which will be returned) */
  switch(trim_header(line)) {
    case 1: type = LINE_TYPE_HEADER_1; break;
    case 2: type = LINE_TYPE_HEADER_2; break;
    default:
    switch(first) {
      case HLP_LIST_NUMBER: type = LINE_TYPE_LIST_NUMBER; break;
      case HLP_LIST_INDENT: type = LINE_TYPE_LIST_INDENT; break;
      case HLP_LIST_BULLET: type = LINE_TYPE_LIST_BULLET; break;
      default:  type = LINE_TYPE_OTHER;       break;
    }
  }

  char * tag = NULL;
  switch(type) {
  case LINE_TYPE_LIST_BULLET: tag = HTML_LIST_ITEM_BULLET; break;
  case LINE_TYPE_LIST_NUMBER: tag = HTML_LIST_ITEM_NUMBER; break;
  case LINE_TYPE_LIST_INDENT: tag = HTML_LIST_ITEM_INDENT; break;
  case LINE_TYPE_HEADER_1:    tag = HTML_HEADER_1;         break;
  case LINE_TYPE_HEADER_2:    tag = HTML_HEADER_2;         break;
  default:                    tag = NULL;                  break;
  }

  while (1) {
    if (make_italic(line) == NULL) break;
  }
  while (1) {
    if (make_bold(line) == NULL) break;
  }
  while (1) {
    if (make_display(line) == NULL) break;
  }
  while (1) {
    if (make_ops(line) == NULL) break;
  }

  while (1) {
    if (unescape_slashes(line) == NULL) break;
  }

  if (tag != NULL) {
    int offset = 0;
    if ((type == LINE_TYPE_LIST_BULLET) ||
        (type == LINE_TYPE_LIST_NUMBER) ||
        (type == LINE_TYPE_LIST_INDENT)) {
      offset = 1;
    }
    sprintf(html, "<%s>%s</%s>\n",
                  tag, line + offset, tag);
  } else {
    sprintf(html, "<p>%s\n", line);
  }

  return type;
}

/******************************************************************************
 *                                                                            *
 *                    Implementation of functions is the API                  *
 *                                                                            *
 ******************************************************************************/

int hlp2html_init(hlp2html_t * hlp2html, const char * css_path,
                  char * html_out, int out_size)
{
  int ret = 0;

  hlp2html->last_line_type = LINE_TYPE_OTHER;

  /* Output HTML header */
  snprintf(html_out, out_size, HTML_HEADER_FORMAT, css_path);

  return ret;
}

int hlp2html_done(hlp2html_t * hlp2html,
                  char * html_out, int out_size)
{
  line_type_t last_type = hlp2html->last_line_type;
  char * close_list_tag;
  int ret = 0;

  html_out[0] = '\0';

  /* Close previous list */
  switch(last_type) {
    case LINE_TYPE_LIST_BULLET: close_list_tag = HTML_LIST_BULLET; break;
    case LINE_TYPE_LIST_INDENT: close_list_tag = HTML_LIST_INDENT; break;
    case LINE_TYPE_LIST_NUMBER: close_list_tag = HTML_LIST_NUMBER; break;
    default:                    close_list_tag = NULL;            break;
  }

  if (close_list_tag != NULL) {
    strcat(html_out, "</");
    strcat(html_out, close_list_tag);
    strcat(html_out, ">");
  }

  /* Output HTML footer */
  strcat(html_out, HTML_FOOTER);

  return ret;
}

int hlp2html_next(hlp2html_t * hlp2html, const char * hlp_lines,
                  char * html_out, int out_size)
{
  const char * help;
  line_type_t last_type = hlp2html->last_line_type;
  int ret = 0;

  help = hlp_lines;

  html_out[0] = '\0';

  /* Go through every help line and convert it into HTML.
   *
   * For the most part, help lines can be converted one by one without
   * needing to know the context. Lists are the exception and are treated
   * accordingly.
   */
  while (1) {
    char * open_list_tag;
    char * close_list_tag;
    char help_line[1000];
    char html_line[1000];
    char * end_help_line;

    memset(help_line, 0, sizeof(help_line));
    end_help_line = strstr(help, "\n");
    if (help[0] == '\0') {
      /* We reached the end of the hlp string
       */
      break;
    } else if (end_help_line != NULL) {
      strncpy(help_line, help, end_help_line - help);
      help = end_help_line + 1;
    } else {
      strncpy(help_line, help, strlen(help));
      help += strlen(help);
    }

    line_type_t type = line2html(help_line, html_line);

    /* Determine whether we are finishing and/or starting a list and what
     * type of list it is.
     */
    open_list_tag = NULL;
    close_list_tag = NULL;
    if (type != last_type) {
      switch(last_type) {
      case LINE_TYPE_LIST_BULLET: close_list_tag = HTML_LIST_BULLET; break;
      case LINE_TYPE_LIST_INDENT: close_list_tag = HTML_LIST_INDENT; break;
      case LINE_TYPE_LIST_NUMBER: close_list_tag = HTML_LIST_NUMBER; break;
      default:                    close_list_tag = NULL;            break;
      }

      switch(type) {
      case LINE_TYPE_LIST_BULLET: open_list_tag = HTML_LIST_BULLET; break;
      case LINE_TYPE_LIST_INDENT: open_list_tag = HTML_LIST_INDENT; break;
      case LINE_TYPE_LIST_NUMBER: open_list_tag = HTML_LIST_NUMBER; break;
      default:
        open_list_tag = NULL;
        type = LINE_TYPE_OTHER;
        break;
      }

      last_type = type;
    }

    /* Close previous list */
    if (close_list_tag != NULL) {
      strcat(html_out, "</");
      strcat(html_out, close_list_tag);
      strcat(html_out, ">");
    }
    /* Open previous list */
    if (open_list_tag != NULL) {
      strcat(html_out, "<");
      strcat(html_out, open_list_tag);
      strcat(html_out, ">");
    }
    strcat(html_out, html_line);
  }

  hlp2html->last_line_type = last_type;

  return ret;
}
