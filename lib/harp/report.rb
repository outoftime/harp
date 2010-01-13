require File.join(File.dirname(__FILE__), 'report', 'method_summary')
require File.join(File.dirname(__FILE__), 'report', 'node')

module Harp
  class Report
    attr_reader :heads
    
    def initialize
      @heads = []
    end

    def total_time
      @heads.inject(0.0) { |time, head| time + head.total_time }
    end

    def add_call_trees(heads)
      heads.each { |head| add_call_tree(head) }
    end
    
    def add_call_tree(root)
      head = Node.new(self, root)
      @heads << head
      @methods_hash ||= {}
      node_stack = [head]
      call_stack = [root]
      child_stack = [root.children.dup]
      until call_stack.empty?
        if child_stack.last.empty?
          node_stack.pop
          call_stack.pop
          child_stack.pop
        else
          call = child_stack.last.pop
          method_summary = @methods_hash[call.to_s] ||= MethodSummary.new(self)
          method_summary << call
          node_stack.push(node_stack.last.add_child(call))
          call_stack.push(call)
          child_stack.push(call.children.dup)
        end
      end
    end

    def methods
      @methods ||=
        begin
          @methods_hash.values.sort do |lmethod, rmethod|
            rmethod.total_time <=> lmethod.total_time
          end
        end
    end

    def run(&block)
      add_call_trees(Harp::Runner.run(&block))
      self
    end

    private

    def add_node_to_methods(node)
      method = @methods_hash[node.to_s] ||= MethodSummary.new(self)
      method << node
      node.children.each do |child|
        add_node_to_methods(child)
      end
    end
  end
end
