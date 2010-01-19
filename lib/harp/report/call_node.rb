module Harp
  class Report
    class CallNode < Node
      include MethodAggregator

      attr_reader :parent, :calls

      def initialize(report, parent)
        super(report)
        @parent = parent
        @calls = []
      end

      def <<(call)
        @calls << call
        call.children.each do |child_call|
          add_child_call(child_call)
        end
      end

      def percent_time_of_parent
        total_time / parent.total_time * 100
      end

      def percent_time_of_total
        total_time / @report.total_time * 100
      end

      def percent_allocations_of_parent
        if parent.total_allocations == 0
          0.0
        else
          total_allocations / parent.total_allocations * 100
        end
      end

      def percent_allocations_of_total
        if @report.total_allocations == 0
          0.0
        else
          total_allocations / @report.total_allocations * 100
        end
      end

      def to_s
        @calls.first.to_s
      end

      def count
        @calls.length
      end
    end
  end
end
