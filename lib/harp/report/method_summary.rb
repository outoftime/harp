module Harp
  class Report
    class MethodSummary
      attr_reader :parent

      def initialize(parent, call = nil)
        @parent = parent
        @calls = []
        self << call if call
      end

      def <<(call)
        @calls << call
        call
      end

      def class_name
        @calls.first.class_name
      end

      def method
        @calls.first.method
      end

      def to_s
        @calls.first.to_s
      end

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
        @total_allocations ||= sum(0) { |call| call.total_allocations }
      end

      def self_allocations
        @self_allocations ||= sum(0) { |call| call.self_allocations }
      end

      def child_allocations
        @child_allocations ||= sum(0) { |call| call.child_allocations }
      end

      def count
        @count_time ||= @calls.length
      end

      def to_s
        @calls.first.to_s
      end

      def time_for_percent
        self_time
      end

      private

      def sum(base = 0.0)
        @calls.inject(base) { |time, item| time + yield(item) }
      end
    end
  end
end
