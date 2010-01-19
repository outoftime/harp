module Harp
  class Report
    module MethodAggregator
      def total_time
        @total_time ||= sum { |call| call.total_time }
      end

      def self_time
        @self_time ||= sum { |call| call.self_time }
      end

      def child_time
        @child_time ||= sum { |call| call.child_time }
      end

      def total_allocations
        @total_allocations ||= sum { |call| call.total_allocations }
      end

      def self_allocations
        @self_allocations ||= sum { |call| call.self_allocations }
      end

      def child_allocations
        @child_allocations ||= sum { |call| call.child_allocations }
      end

      private

      def sum
        calls.inject(0) { |sum, call| sum + yield(call) }
      end
    end
  end
end
