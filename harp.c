#include "ruby.h"
#include "node.h"

struct _harp_call_element {
	VALUE name;
  VALUE event_name;
  int time;
  struct _harp_call_element * next;
};
typedef struct _harp_call_element harp_call_element;

harp_call_element * root = NULL;
harp_call_element * current = NULL;

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
	harp_call_element * cursor;

	rb_remove_event_hook(harp_handle_event);
	int i;
	for(cursor = root ; cursor ; cursor = cursor->next) {
		rb_funcall(rb_cObject, rb_intern("puts"), 1, cursor->name);
		rb_funcall(rb_cObject, rb_intern("puts"), 1, cursor->event_name);
	}
}

void harp_handle_event(rb_event_t event, NODE *node, VALUE self, ID id, VALUE klass) {
	harp_call_element * new_call_node;

  new_call_node = (harp_call_element *)malloc(sizeof(harp_call_element));
  new_call_node->next = NULL;
	switch(event) {
	case RUBY_EVENT_CALL:
	case RUBY_EVENT_C_CALL:
	  new_call_node->name = ID2SYM(id);
    new_call_node->event_name = ID2SYM(rb_intern("call"));
		break;

	case RUBY_EVENT_RETURN:
  case RUBY_EVENT_C_RETURN:
    new_call_node->name = Qnil;
    new_call_node->event_name = ID2SYM(rb_intern("return"));
    break;
  }
  if(!root) {
    root = new_call_node;
    current = root;
  } else {
    current->next = new_call_node;
    current = new_call_node;
  }
}
