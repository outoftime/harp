module Harp
  module Formatter
    autoload :Text, File.join(File.dirname(__FILE__), 'formatter', 'text')
    autoload :Xml, File.join(File.dirname(__FILE__), 'formatter', 'xml')
    autoload :Dot, File.join(File.dirname(__FILE__), 'formatter', 'dot')

    class Base
      attr_writer :min_percent_time_of_parent
      attr_writer :min_percent_time_of_total
      attr_writer :min_aggregate_percent_time_of_total
      attr_writer :min_percent_allocations_of_parent
      attr_writer :min_percent_allocations_of_total
      attr_writer :min_aggregate_percent_allocations_of_total

      def initialize(report)
        @report = report
        @filters = []
        @min_percent_time_of_parent =
          @min_percent_time_of_total =
          @min_aggregate_percent_time_of_total =
          @min_percent_allocations_of_parent =
          @min_percent_allocations_of_total =
          @min_aggregate_percent_allocations_of_total = 0.0
      end

      def filter(&block)
        @filters << block
      end

      def filter_by_signature(expr)
        filter do |node|
          node.to_s =~ expr
        end
      end

      def format_signature(&block)
        @signature_formatter = block
      end

      private

      def stop_node?(node)
        time_stop_node?(node) && allocations_stop_node?(node)
      end

      def time_stop_node?(node)
        node.percent_time_of_parent < @min_percent_time_of_parent ||
          node.percent_time_of_total < @min_percent_time_of_total ||
          node.aggregate_percent_time_of_total < @min_aggregate_percent_time_of_total
      end

      def allocations_stop_node?(node)
        node.percent_allocations_of_parent < @min_percent_allocations_of_parent ||
          node.percent_allocations_of_total < @min_percent_allocations_of_total ||
          node.aggregate_percent_allocations_of_total < @min_aggregate_percent_allocations_of_total
      end

      def skip_node?(node)
        @filters.any? { |filter| filter.call(node) }
      end

      def node_signature(node)
        if @signature_formatter
          @signature_formatter.call(node)
        end || node.to_s
      end
    end
  end
end
