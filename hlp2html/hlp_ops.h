#ifndef _HLP_OPS_H_
#define _HLP_OPS_H_
/**
 * Data to convert operators from hlp format to HTML.
 *
 * This file has the necessary information to do the mapping between the ASCII hlp fprmat and and the HTML form. In addition it describes
 * the type of button each operator is located at.
 */

typedef enum button_type_e
{
  BUTTON_WHITE,      // Digits, '+/-' and '.'
  BUTTON_YELLOW,     // Arithmetic, '2nd', 'INV' and 'CLR' (We use TI-59's colors)
  BUTTON_DEFAULT,    // Default for primary operators
  BUTTON_SECONDARY,  // Secondary operators (preceded by 2nd)
} button_type_t;

typedef struct op_s
{
  char *help_op;              // Name hlp files
  button_type_t button_type;  // Type of button operator is at
  char *html_op;              // Name in HTML
} op_t;

/** List of TI-57 operators. */
const op_t ops[] = {
    {"0",     BUTTON_WHITE,     "0"},
    {"1",     BUTTON_WHITE,     "1"},
    {"2",     BUTTON_WHITE,     "2"},
    {"3",     BUTTON_WHITE,     "3"},
    {"4",     BUTTON_WHITE,     "4"},
    {"5",     BUTTON_WHITE,     "5"},
    {"6",     BUTTON_WHITE,     "6"},
    {"7",     BUTTON_WHITE,     "7"},
    {"8",     BUTTON_WHITE,     "8"},
    {"9",     BUTTON_WHITE,     "9"},
    {"cl'",   BUTTON_SECONDARY, "CL'"},
    {"2nd",   BUTTON_YELLOW,    "2nd"},
    {"inv",   BUTTON_YELLOW,    "INV"},
    {"lnx",   BUTTON_DEFAULT,   "lnx"},
    {"ce",    BUTTON_DEFAULT,   "CE"},
    {"clr",   BUTTON_DEFAULT,   "CLR"},
    {"log",   BUTTON_SECONDARY, "log"},
    {"c.t",   BUTTON_SECONDARY, "C.t"},
    {"tan",   BUTTON_SECONDARY, "tan"},
    {"lrn",   BUTTON_DEFAULT,   "LRN"},
    {"x:t",   BUTTON_DEFAULT,   "x:t"},
    {"x2",    BUTTON_DEFAULT,   "x&#178;"},
    {"vx",    BUTTON_DEFAULT,   "&#8730;x"},
    {"1/x",   BUTTON_DEFAULT,   "1/x"},
    {"pgm",   BUTTON_SECONDARY, "Pgm"},
    {"p->r",  BUTTON_SECONDARY, "P&#8594;R"},
    {"sin",   BUTTON_SECONDARY, "sin"},
    {"cos",   BUTTON_SECONDARY, "cos"},
    {"ind",   BUTTON_SECONDARY, "Ind"},
    {"sst",   BUTTON_DEFAULT,   "SST"},
    {"sto",   BUTTON_DEFAULT,   "STO"},
    {"rcl",   BUTTON_DEFAULT,   "RCL"},
    {"sum",   BUTTON_DEFAULT,   "SUM"},
    {"yx",    BUTTON_DEFAULT,   "y<sup>x</sup>"},
    {"ins",   BUTTON_SECONDARY, "Ins"},
    {"cms",   BUTTON_SECONDARY, "CMs"},
    {"exc",   BUTTON_SECONDARY, "Exc"},
    {"prd",   BUTTON_SECONDARY, "Prd"},
    {"|x|",   BUTTON_SECONDARY, "|x|"},
    {"bst",   BUTTON_DEFAULT,   "BST"},
    {"ee",    BUTTON_DEFAULT,   "EE"},
    {"(",     BUTTON_DEFAULT,   "("},
    {")",     BUTTON_DEFAULT,   ")"},
    {"/",     BUTTON_YELLOW,    "&#247;"},
    {"del",   BUTTON_SECONDARY, "Del"},
    {"fix",   BUTTON_SECONDARY, "Fix"},
    {"int",   BUTTON_SECONDARY, "Int"},
    {"deg",   BUTTON_SECONDARY, "Deg"},
    {"gto",   BUTTON_DEFAULT,   "GTO"},
    {"*",     BUTTON_YELLOW,    "&#215;"},
    {"pause", BUTTON_SECONDARY, "Pause"},
    {"x=t",   BUTTON_SECONDARY, "x=t"},
    {"nop",   BUTTON_SECONDARY, "Nop"},
    {"rad",   BUTTON_SECONDARY, "Rad"},
    {"sbr",   BUTTON_DEFAULT,   "SBR"},
    {"-",     BUTTON_YELLOW,    "-"},
    {"lbl",   BUTTON_SECONDARY, "Lbl"},
    {"x>=t",  BUTTON_SECONDARY, "x&#8805;t"},
    {"s+",    BUTTON_SECONDARY, "&#8721;+"},
    {"xbar",  BUTTON_SECONDARY, "x&#772;"},
    {"grad",  BUTTON_SECONDARY, "Grad"},
    {"rst",   BUTTON_DEFAULT,   "RST"},
    {"+",     BUTTON_YELLOW,    "+"},
    {"d.ms",  BUTTON_SECONDARY, "D.MS"},
    {"pi",    BUTTON_SECONDARY, "&#960;"},
    {"r/s",   BUTTON_DEFAULT,   "R/S"},
    {".",     BUTTON_WHITE,     "."},
    {"+/-",   BUTTON_WHITE,     "+/-"},
    {"=",     BUTTON_YELLOW,    "="},
    {"dsz",   BUTTON_SECONDARY, "Dsz"},
    {"s2",    BUTTON_SECONDARY, "&#963;&#178;"},
};
#endif
