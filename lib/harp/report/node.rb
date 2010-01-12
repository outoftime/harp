module Harp
  class Report
    class Node < MethodSummary
      def initialize(call = nil)
        @children = {}
        super
      end

      def <<(call)
        super
        call.children.each do |child|
          child_node = @children[child.to_s] ||= Node.new
          child_node << child
        end
        call
      end

      def children
        @children.values
      end

      def time_for_percent
        total_time
      end
    end
  end
end
