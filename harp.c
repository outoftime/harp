#include "ruby.h"
#include "node.h"

struct _harp_call_element {
	VALUE name;
  rb_event_t event;
  int time;
  struct _harp_call_element * next;
};
typedef struct _harp_call_element harp_call_element;

struct _harp_tree_node {
	harp_call_element * call;
	struct _harp_tree_node * parent;
	struct _harp_tree_node * next;
	struct _harp_tree_node * first_child;
	struct _harp_tree_node * last_child;
};
typedef struct _harp_tree_node harp_tree_node;

harp_call_element * root = NULL;
harp_call_element * current = NULL;

VALUE Harp = Qnil;

void Init_harp();
void harp_handle_event(rb_event_t event, NODE *node, VALUE self, ID id, VALUE klass);
harp_tree_node * harp_build_tree(harp_tree_node * current_node, harp_call_element * call);
void harp_print_tree(harp_tree_node * current, int indent);

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
	harp_tree_node * tree;

	rb_remove_event_hook(harp_handle_event);
	tree = harp_build_tree(NULL, root);
	harp_print_tree(tree, 0);
}

void harp_handle_event(rb_event_t event, NODE *node, VALUE self, ID id, VALUE klass) {
	harp_call_element * new_call_node;

  new_call_node = (harp_call_element *)malloc(sizeof(harp_call_element));
  new_call_node->next = NULL;

	switch(event) {
	case RUBY_EVENT_CALL:
	case RUBY_EVENT_C_CALL:
	  new_call_node->name = ID2SYM(id);
		break;
  }

	new_call_node->event = event;
  if(!root) {
    root = new_call_node;
    current = root;
  } else {
    current->next = new_call_node;
    current = new_call_node;
  }
}

harp_tree_node * harp_build_tree(harp_tree_node * current_node, harp_call_element * call) {
	harp_tree_node * next_node;
	switch(call->event) {
	case RUBY_EVENT_CALL:
	case RUBY_EVENT_C_CALL:
		next_node = (harp_tree_node *)malloc(sizeof(harp_tree_node));
		next_node->call = call;
		next_node->parent = current_node;
		next_node->next = NULL;
		next_node->first_child = NULL;
		next_node->last_child = NULL;

		if(current_node) {
			if(current_node->last_child) {
				current_node->last_child->next = next_node;
			} else {
				current_node->first_child = next_node;
			}
			current_node->last_child = next_node;
		}

		if(call->next) {
			harp_build_tree(next_node, call->next);
		}
		return next_node;
	case RUBY_EVENT_RETURN:
	case RUBY_EVENT_C_RETURN:
		if(call->next) {
			harp_build_tree(current_node->parent, call->next);
		}
		return NULL;
	}
}

void harp_print_tree(harp_tree_node * current, int indent) {
	rb_funcall(rb_cObject, rb_intern("puts"), 1, INT2NUM(indent));
	rb_funcall(rb_cObject, rb_intern("puts"), 1, current->call->name);
	if(current->first_child) {
		harp_print_tree(current->first_child, indent + 1);
	}
	if(current->next) {
		harp_print_tree(current->next, indent);
	}
}
