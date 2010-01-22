module Harp
  class Report
    class RootNode < Node
      def total_time
        @total_time ||= children.inject(0) { |time, child| time + child.total_time }
      end
      alias_method :child_time, :total_time
      
      def self_time
        0.0
      end

      def total_allocations
        @total_allocations ||= children.inject(0) { |allocations, child| allocations + child.total_allocations }
      end
      alias_method :child_allocations, :total_allocations

      def self_allocations
        0
      end

      def percent_time_of_parent
        100.0
      end
      alias_method :percent_time_of_total, :percent_time_of_parent
      alias_method :aggregate_percent_time_of_total, :percent_time_of_parent

      def percent_allocations_of_parent
        100.0
      end
      alias_method :percent_allocations_of_total, :percent_allocations_of_parent
      alias_method :aggregate_percent_allocations_of_total, :percent_allocations_of_parent

      def count
        children.inject(0) { |sum, child| child.count }
      end
      alias_method :aggregate_count, :count

      def to_s
        "ROOT"
      end

      private

      def sum
        children.inject(0) { |sum, child| sum + yield(child) }
      end
    end
  end
end
