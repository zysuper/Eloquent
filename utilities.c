/*
 * utilities.c
 *
 * Defines the utility functions only depends on the operations provided by object.c and type.h
 *
 *  Created on: 2013年7月20日
 *      Author: liutos
 */
#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include "object.h"
#include "type.h"

lt *booleanize(int value) {
  if (value == 0)
    return the_false;
  else
    return the_true;
}

int is_label(lt *object) {
  return issymbol(object);
}

int is_symbol_bound(lt *symbol) {
  return isundef(symbol_value(symbol))? FALSE: TRUE;
}

int is_macro_form(lt *form) {
  if (!ispair(form))
    return FALSE;
  if (!issymbol(pair_head(form)))
    return FALSE;
  lt *symbol = pair_head(form);
  return is_symbol_bound(symbol) && ismacro(symbol_value(symbol));
}

int is_tag_list(lisp_object_t *object, lisp_object_t *tag) {
  return ispair(object) && (pair_head(object) == tag);
}

lt *list1(lt *element) {
  return make_pair(element, make_empty_list());
}

lt *list2(lt *e1, lt *e2) {
  return make_pair(e1, list1(e2));
}

lt *list3(lt *e1, lt *e2, lt *e3) {
  return make_pair(e1, list2(e2, e3));
}

lt *lt_append2(lt *l1, lt *l2) {
  if (isnull(l1))
    return l2;
  else
    return make_pair(pair_head(l1), lt_append2(pair_tail(l1), l2));
}

lisp_object_t *lt_append_n(lisp_object_t *list0, ...) {
  va_list ap;
  va_start(ap, list0);
  lisp_object_t *next = va_arg(ap, lisp_object_t *);
  while (next != NULL) {
    list0 = lt_append2(list0, next);
    next = va_arg(ap, lisp_object_t *);
  }
  return list0;
}

int pair_length(lisp_object_t *pair) {
  if (isnull(pair))
    return 0;
  int length = 0;
  while (!isnull(pair)) {
    assert(ispair(pair));
    length++;
    pair = pair_tail(pair);
  }
  return length;
}

lisp_object_t *reader_error(char *format, ...) {
  static char msg[1000];
  va_list ap;
  va_start(ap, format);
  vsprintf(msg, format, ap);
  return make_exception(strdup(msg), TRUE);
}

char *sb2string(string_builder_t *sb) {
  sb->string[sb->index] = '\0';
  return sb->string;
}

void sb_add_char(string_builder_t *sb, char c) {
  if (sb->index >= sb->length) {
    sb->length += 20;
    sb->string = realloc(sb->string, sb->length * sizeof(char));
  }
  sb->string[sb->index] = c;
  sb->index++;
}

lt *signal_exception(char *message) {
  return make_exception(message, TRUE);
}

lt *signal_typerr(char *type_name) {
  char msg[256];
  sprintf(msg, "Argument is not of type %s", type_name);
  return signal_exception(strdup(msg));
}
