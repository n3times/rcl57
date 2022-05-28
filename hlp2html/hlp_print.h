#ifndef _HLP_PRINT_H_
#define _HLP_PRINT_H_
/**
 * \file hlp_print.h
 *
 * \brief Data to convert print characters from hlp format to HTML.
 *
 * Hlp files use an ASCII character to represent a print character. Many
 * print characters (such as 'A') are already in ASCII form. The ones that
 * are not, such as the square root symbol, are represented as stated here.
 */

typedef struct print_s
{
  char hlp_char;      /*!< Character as represented in a hlp file */
  char * html_string; /*!< Character in HTML form */
} print_t;

/**
 * Characters not in this list (such as 'A') do not need special translation
 * into HTML.
 */
extern print_t special_prints[13];
#endif
