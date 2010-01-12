module Harp
  module Formatter
    class Text
      def initialize(report)
        @report = report
      end

      def write(io = $stdout)
        write_method_summary(io)
        io.puts('')
        write_call_tree(io)
      end

      private

      def write_header(io)
        io.puts(sprintf(
          '%-10s  %-10s  %-10s  %-5s  %s',
          'total',
          'self',
          'child',
          'count',
          'call'
        ))
      end

      def write_method_summary(io)
        io.puts("=== METHOD SUMMARY ===")
        write_header(io)
        @report.methods.each do |method|
          write_node(io, method)
        end
      end

      def write_call_tree(io)
        io.puts("=== CALL TREE ===")
        write_header(io)
        write_node_tree(io, @report.head)
      end

      def write_node(io, node, indent = 0)
        io.puts(sprintf(
          "%.8f  %.8f  %.8f  %5d  #{'  '*indent}%s",
          node.total_time,
          node.self_time,
          node.child_time,
          node.count,
          node
        ))
      end

      def write_node_tree(io, node, indent = 0)
        write_node(io, node, indent)
        node.children.each { |child| write_node_tree(io, child, indent + 1) }
      end
    end
  end
end
