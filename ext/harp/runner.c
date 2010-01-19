#include "time.h"
#include "sys/times.h"
#include "assert.h"
#include "ruby.h"
#include "node.h"

struct _harp_call_element {
	VALUE klass;
	ID name;
  rb_event_t event;
  double clock;
	unsigned long allocated_objects;
  struct _harp_call_element * next;
};
typedef struct _harp_call_element harp_call_element;

struct _harp_tree_node {
	harp_call_element * call;
	VALUE klass;
	VALUE name;
	double time;
	unsigned long allocations;
	struct _harp_tree_node * parent;
	struct _harp_tree_node * next;
	struct _harp_tree_node * first_child;
	struct _harp_tree_node * last_child;
};
typedef struct _harp_tree_node harp_tree_node;

harp_call_element * root = NULL;
harp_call_element * current = NULL;

VALUE Harp_Runner = Qnil;

void Init_runner();

void harp_handle_event(rb_event_t event,
											 NODE *node,
											 VALUE self,
											 ID id,
										   VALUE klass);

harp_tree_node * harp_build_tree(harp_tree_node * current_node,
															   harp_call_element * call,
																 int * counter);

void harp_print_tree(harp_tree_node * current,
										 int indent);

VALUE harp_build_ruby_trees(harp_tree_node * root);

VALUE method_start(VALUE self);

VALUE method_stop(VALUE self);

void Init_runner()
{
	Harp_Runner = rb_eval_string("Harp::Runner");
	rb_define_singleton_method(Harp_Runner, "start", method_start, 0);
	rb_define_singleton_method(Harp_Runner, "stop", method_stop, 0);
}

VALUE method_start(VALUE self)
{
	rb_add_event_hook(harp_handle_event, RUBY_EVENT_CALL | RUBY_EVENT_C_CALL |
																       RUBY_EVENT_RETURN | RUBY_EVENT_C_RETURN);

	return Qnil;
}

VALUE method_stop(VALUE self)
{
	harp_call_element * cursor;
	harp_tree_node * tree;
	int counter;

	counter = 0;

	rb_remove_event_hook(harp_handle_event);
	tree = harp_build_tree(NULL, root, &counter);
	// harp_print_tree(tree, 0);
	return harp_build_ruby_trees(tree);
}

void harp_handle_event(rb_event_t event,
											 NODE *node,
											 VALUE self,
											 ID id,
										   VALUE klass)
{
	harp_call_element * new_call_node;
	struct timeval current_time;
	double current_clock;
	gettimeofday(&current_time, NULL);
	current_clock = current_time.tv_sec + (current_time.tv_usec / 1000000.0);

  new_call_node = ALLOC(harp_call_element);
  new_call_node->next = NULL;

	switch(event) {
	case RUBY_EVENT_CALL:
	case RUBY_EVENT_C_CALL:
		new_call_node->klass = klass;
	  new_call_node->name = id;
		break;
  }

	new_call_node->event = event;
	new_call_node->clock = current_clock;
	new_call_node->allocated_objects = rb_os_allocated_objects();
  if(!root) {
    root = new_call_node;
    current = root;
  } else {
    current->next = new_call_node;
    current = new_call_node;
  }
}

harp_tree_node * harp_build_tree(harp_tree_node * current_node,
																 harp_call_element * call,
																 int * counter)
{
	harp_tree_node * first_top_node = NULL;
	harp_tree_node * last_top_node = NULL;
	harp_tree_node * next_node = NULL;
	while(call->next) { // This means we don't get the very last call, which is to #stop
		switch(call->event) {
		case RUBY_EVENT_CALL:
		case RUBY_EVENT_C_CALL:
			next_node = ALLOC(harp_tree_node);
			if(!first_top_node) {
				first_top_node = next_node;
			}
			next_node->klass = call->klass;
			if(call->name == 1) {
				next_node->name = 0;
			} else {
				next_node->name = ID2SYM(call->name);
			}
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
			} else if(last_top_node) {
				last_top_node->next = next_node;
      }

      last_top_node = next_node;

			current_node = next_node;
			break;
		case RUBY_EVENT_RETURN:
		case RUBY_EVENT_C_RETURN:
			current_node->time = (double) call->clock - (double) current_node->call->clock;
			current_node->allocations = call->allocated_objects - current_node->call->allocated_objects;
			current_node = current_node->parent;
			break;
		}
		call = call->next;
	}
	return first_top_node;
}

void harp_print_tree(harp_tree_node * current,
										 int indent)
{
	if(current->klass && 0) { // XXX
		rb_funcall(rb_cObject, rb_intern("puts"), 1, current->klass);
	}
	if(current->name) {
		rb_funcall(rb_cObject, rb_intern("puts"), 1, current->name);
	}
	rb_funcall(rb_cObject, rb_intern("puts"), 1, rb_float_new(current->time));
	rb_funcall(rb_cObject, rb_intern("puts"), 1, INT2NUM(indent));
	if(current->first_child) {
		harp_print_tree(current->first_child, indent + 1);
	}
	if(current->next) {
		harp_print_tree(current->next, indent);
	}
}

VALUE harp_build_ruby_trees(harp_tree_node * first_top_node)
{
	VALUE harp_call_class = rb_eval_string("Harp::Call");
	VALUE ruby_nodes = rb_ary_new();
	VALUE new_ruby_node;
	harp_tree_node * current_node;


	for (current_node = first_top_node; current_node; current_node = current_node->next) {
    VALUE allocations;
		new_ruby_node = rb_funcall(harp_call_class,
														   rb_intern("new"),
															 4,
															 rb_str_new2(rb_class2name(current_node->klass)),
															 current_node->name,
															 rb_float_new(current_node->time),
															 ULONG2NUM(current_node->allocations));
		rb_ary_push(ruby_nodes, new_ruby_node);
		rb_funcall(new_ruby_node, rb_intern("add_children"), 1, harp_build_ruby_trees(current_node->first_child));
	}

	return ruby_nodes;
}
