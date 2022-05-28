#ifndef _HLP2HTML_INTERNAL_H_
#define _HLP2HTML_INTERNAL_H_

/*
 */

typedef enum line_type_e
{
  LINE_TYPE_LIST_INDENT,
  LINE_TYPE_LIST_BULLET,
  LINE_TYPE_LIST_NUMBER,
  LINE_TYPE_HEADER_1,
  LINE_TYPE_HEADER_2,
  LINE_TYPE_OTHER,
} line_type_t;

struct hlp2html_s
{
  line_type_t last_line_type;
};
#endif
