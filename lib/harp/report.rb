require File.join(File.dirname(__FILE__), 'report', 'method_summary')
require File.join(File.dirname(__FILE__), 'report', 'node')

module Harp
  class Report
    attr_reader :head
    
    def add_call_tree(root)
      @head = Node.new(root)
    end

    def run(&block)
      add_call_tree(Harp::Runner.run(&block))
      self
    end

    def methods
      @methods ||=
        begin
          @methods_hash = {}
          add_node_to_methods(@head)
          @methods_hash.values.sort do |lmethod, rmethod|
            rmethod.total_time <=> lmethod.total_time
          end
        end
    end

    private

    def add_node_to_methods(node)
      method = @methods_hash[node.to_s] ||= MethodSummary.new
      method << node
      node.children.each do |child|
        add_node_to_methods(child)
      end
    end
  end
end
