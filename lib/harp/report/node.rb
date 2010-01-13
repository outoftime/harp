module Harp
  class Report
    class Node < MethodSummary
      def initialize(parent, call = nil)
        @children = {}
        super
      end

      def children
        @children.values
      end

      def add_child(call)
        child_node = @children[call.to_s] ||= Node.new(self)
        child_node << call
        child_node
      end

      def time_for_percent
        total_time
      end
    end
  end
end
