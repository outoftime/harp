module Harp
  class Report
    class MethodSummary
      include MethodAggregator

      attr_reader :calls

      def initialize(report)
        @report = report
        @calls = []
      end

      def <<(call)
        @calls << call
        call
      end

      def percent_time_of_total
        total_time / @report.total_time * 100
      end

      def percent_allocations_of_total
        total_allocations.to_f / @report.total_allocations.to_f * 100
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
