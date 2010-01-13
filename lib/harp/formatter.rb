module Harp
  module Formatter
    autoload :Text, File.join(File.dirname(__FILE__), 'formatter', 'text')
    autoload :Xml, File.join(File.dirname(__FILE__), 'formatter', 'xml')
    autoload :Dot, File.join(File.dirname(__FILE__), 'formatter', 'dot')

    class Base
      attr_writer :min_percent
      attr_writer :min_total_percent

      def initialize(report)
        @report = report
        @filters = []
        @min_percent = @min_total_percent = 0.0
      end

      def filter(&block)
        @filters << block
      end

      def filter_by_signature(class_name, *methods)
        methods = [nil] if methods.empty?
        methods.each do |method|
          filter do |node|
            match = true
            if class_name
              if class_name.is_a?(String)
                match = class_name == node.class_name
              else
                match = class_name =~ node.class_name
              end
            end
            if method && match
              if method.is_a?(String)
                match = method == node.method.to_s
              else
                match = method =~ node.method.to_s
              end
            end
            match
          end
        end
      end

      def format_signature(&block)
        @signature_formatter = block
      end

      private

      def stop_node?(node)
        percent = node.time_for_percent.to_f / node.parent.total_time.to_f * 100.0
        total_percent = node.time_for_percent.to_f / @report.total_time.to_f * 100.0
        percent < @min_percent || total_percent < @min_total_percent
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
