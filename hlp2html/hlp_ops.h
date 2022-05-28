#ifndef _HLP_OPS_H_
#define _HLP_OPS_H_
/**
 * \file hlp_ops.h
 *
 * \brief Data to convert operators from hlp format to HTML.
 *
 * Operators are written in hlp files in an ASCII (and therefore necessarily
 * simplified) form. This file has the necessary information to do the mapping
 * between the ASCII and the HTML form. In addition it describes the type
 * of button each operator is located at.
 */

typedef enum button_type_e
{
  BUTTON_WHITE,   /*!< A few buttons, notably the digits, are white */
  BUTTON_YELLOW,  /*!< A few others, notably "2nd" are yellow */
  BUTTON_BROWN,   /*!< The majority are brown */
  BUTTON_ABOVE,   /*!< Secondary operators are above the buttons */
  BUTTON_VIRTUAL, /*!< Some operators (eg. indirect ops) are not on keyboard */
} button_type_t;

typedef struct op_s
{
  char * help_op;            /*!< Operator name as it appears in a hlp file */
  button_type_t button_type; /*!< Type of button operator is at */
  char * html_op;            /*!< Operator name in HTML */
} op_t;

/**
 * There are 100 "operators" for the TI-59. These operations appear in a
 * program listing with a code from 00 to 99.
 */
const op_t ops[] = {
    {"0",    BUTTON_WHITE,  "0"},
    {"1",    BUTTON_WHITE,  "1"},
    {"2",    BUTTON_WHITE,  "2"},
    {"3",    BUTTON_WHITE,  "3"},
    {"4",    BUTTON_WHITE,  "4"},
    {"5",    BUTTON_WHITE,  "5"},
    {"6",    BUTTON_WHITE,  "6"},
    {"7",    BUTTON_WHITE,  "7"},
    {"8",    BUTTON_WHITE,  "8"},
    {"9",    BUTTON_WHITE,  "9"},
    {"e'",   BUTTON_ABOVE,  "E'"},
    {"a",    BUTTON_BROWN,  "A"},
    {"b",    BUTTON_BROWN,  "B"},
    {"c",    BUTTON_BROWN,  "C"},
    {"d",    BUTTON_BROWN,  "D"},
    {"e",    BUTTON_BROWN,  "E"},
    {"a'",   BUTTON_ABOVE,  "A'"},
    {"b'",   BUTTON_ABOVE,  "B'"},
    {"c'",   BUTTON_ABOVE,  "C'"},
    {"d'",   BUTTON_ABOVE,  "D'"},
    {"cl'",  BUTTON_ABOVE,  "CL'"},
    {"2nd",  BUTTON_YELLOW, "2nd"},
    {"inv",  BUTTON_YELLOW,  "INV"},
    {"lnx",  BUTTON_BROWN,  "lnx"},
    {"ce",   BUTTON_BROWN,  "CE"},
    {"clr",  BUTTON_BROWN, "CLR"},
    {"2n'",  BUTTON_ABOVE,  "2n'"},
    {"in'",  BUTTON_ABOVE,  "IN'"},
    {"log",  BUTTON_ABOVE,  "log"},
    {"c.t",   BUTTON_ABOVE, "C.t"},
    {"tan",  BUTTON_ABOVE,  "tan"},
    {"lrn",  BUTTON_BROWN,  "LRN"},
    {"x:t",  BUTTON_BROWN,  "x:t"},
    {"x2",   BUTTON_BROWN,  "x&#178;"},
    {"vx",   BUTTON_BROWN,  "&#8730;x"},
    {"1/x",  BUTTON_BROWN,  "1/x"},
    {"pgm",  BUTTON_ABOVE,  "Pgm"},
    {"p/r",  BUTTON_ABOVE,  "P&#8594;R"},
    {"sin",  BUTTON_ABOVE,  "sin"},
    {"cos",  BUTTON_ABOVE,  "cos"},
    {"ind",  BUTTON_ABOVE,  "Ind"},
    {"sst",  BUTTON_BROWN,  "SST"},
    {"sto",  BUTTON_BROWN,  "STO"},
    {"rcl",  BUTTON_BROWN,  "RCL"},
    {"sum",  BUTTON_BROWN,  "SUM"},
    {"yx",   BUTTON_BROWN,  "y<sup>x</sup>"},
    {"ins",  BUTTON_ABOVE,  "Ins"},
    {"cms",  BUTTON_ABOVE,  "CMs"},
    {"exc",  BUTTON_ABOVE,  "Exc"},
    {"prd",  BUTTON_ABOVE,  "Prd"},
    {"|x|",  BUTTON_ABOVE,  "|x|"},
    {"bst",  BUTTON_BROWN,  "BST"},
    {"ee",   BUTTON_BROWN,  "EE"},
    {"(",    BUTTON_BROWN,  "("},
    {")",    BUTTON_BROWN,  ")"},
    {"/",    BUTTON_YELLOW, "&#247;"},
    {"del",  BUTTON_ABOVE,  "Del"},
    {"eng",  BUTTON_ABOVE,  "Eng"},
    {"fix",  BUTTON_ABOVE,  "Fix"},
    {"int",  BUTTON_ABOVE,  "Int"},
    {"deg",  BUTTON_ABOVE,  "Deg"},
    {"gto",  BUTTON_BROWN,  "GTO"},
    {"pg*",  BUTTON_VIRTUAL,"Pg*"},
    {"ex*",  BUTTON_VIRTUAL,"Ex*"},
    {"pd*",  BUTTON_VIRTUAL,"Pd*"},
    {"*",    BUTTON_YELLOW, "&#215;"},
    {"pau",  BUTTON_ABOVE,  "Pause"},
    {"x=t",  BUTTON_ABOVE,  "x=t"},
    {"nop",  BUTTON_ABOVE,  "Nop"},
    {"op",   BUTTON_ABOVE,  "Op"},
    {"rad",  BUTTON_ABOVE,  "Rad"},
    {"sbr",  BUTTON_BROWN,  "SBR"},
    {"st*",  BUTTON_VIRTUAL,"ST*"},
    {"rc*",  BUTTON_VIRTUAL,"RC*"},
    {"sm*",  BUTTON_VIRTUAL,"SM*"},
    {"-",    BUTTON_YELLOW, "-"},
    {"lbl",  BUTTON_ABOVE,  "Lbl"},
    {"x>=t", BUTTON_ABOVE,  "x&#8805;t"},
    {"s+",   BUTTON_ABOVE,  "&#8721;+"},
    {"avg",  BUTTON_ABOVE,  "x&#772;"},
    {"var",  BUTTON_ABOVE,  "&#963&#178;"},
    {"grd",  BUTTON_ABOVE,  "Grad"},
    {"rst",  BUTTON_BROWN,  "RST"},
    {"hir",  BUTTON_VIRTUAL,"HIR"},
    {"go*",  BUTTON_VIRTUAL,"GO*"},
    {"op*",  BUTTON_VIRTUAL,"Op*"},
    {"+",    BUTTON_YELLOW, "+"},
    {"stf",  BUTTON_ABOVE,  "St flg"},
    {"iff",  BUTTON_ABOVE,  "If flg"},
    {"d.ms", BUTTON_ABOVE,  "D.MS"},
    {"pi",   BUTTON_ABOVE,  "&#960;"},
    {"lst",  BUTTON_ABOVE,  "List"},
    {"r/s",  BUTTON_BROWN,  "R/S"},
    {"rtn",  BUTTON_VIRTUAL,"RTN"},
    {".",    BUTTON_WHITE,  "."},
    {"+/-",  BUTTON_WHITE,  "+/-"},
    {"=",    BUTTON_YELLOW, "="},
    {"wrt",  BUTTON_ABOVE,  "Write"},
    {"dsz",  BUTTON_ABOVE,  "Dsz"},
    {"adv",  BUTTON_ABOVE,  "Adv"},
    {"prt",  BUTTON_ABOVE,  "Prt"},
};
#endif
