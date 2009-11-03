#include "ruby.h"
#include "node.h"

struct harp_call_node {
  VALUE * name;
  struct harp_call_node * next;
};

struct harp_call_node* root = NULL;
struct harp_call_node* current = NULL;

VALUE Harp = Qnil;

void Init_harp();
void harp_handle_event(rb_event_t event, NODE *node, VALUE self, ID id, VALUE klass);

VALUE method_start(VALUE self);
VALUE method_stop(VALUE self);

void Init_harp() {
  Harp = rb_define_module("Harp");
  rb_define_method(Harp, "start", method_start, 0);
  rb_define_method(Harp, "stop", method_stop, 0);
}

VALUE method_start(VALUE self) {
  rb_add_event_hook(harp_handle_event, RUBY_EVENT_CALL | RUBY_EVENT_C_CALL | RUBY_EVENT_RETURN | RUBY_EVENT_C_RETURN);

  return Qnil;
}

VALUE method_stop(VALUE self) {
  struct harp_call_node *cursor;

  rb_remove_event_hook(harp_handle_event);
  for(cursor = root ; cursor ; cursor = cursor->next) {
    rb_funcall(rb_cObject, rb_intern("puts"), 1, self);
  }
}

void harp_handle_event(rb_event_t event, NODE *node, VALUE self, ID id, VALUE klass) {
  struct harp_call_node call_node;
  VALUE value = Qnil;
  call_node.name = &value;
  call_node.next = 0;
  if(!root) {
    root = &call_node;
    current = root;
  } else {
    current->next = &call_node;
    current = &call_node;
  }
}
