module Harp
  class Report
    class Node
      def initialize(report)
        @report = report
        @children = {}
      end

      def children
        @children.values
      end

      def add_child_call(child_call)
        method_summary = @report.method_summary(child_call)
        child_node = @children[child_call.to_s] ||= CallNode.new(@report, self, method_summary)
        child_node << child_call
        child_node
      end
    end
  end
end
