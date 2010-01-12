module Harp
  module Formatter
    class Text
      def initialize(report)
        @report = report
      end

      def write(io = $stdout)
        io.puts(sprintf(
          '%-10s  %-10s  %-10s  %-5s  %s',
          'total',
          'self',
          'child',
          'count',
          'call'
        ))
        write_node(io, @report.head)
      end

      private

      def write_node(io, node, indent = 0)
        io.puts(sprintf(
          "%.8f  %.8f  %.8f  %5d  #{'  '*indent}%s",
          node.total_time,
          node.self_time,
          node.child_time,
          node.count,
          node
        ))
        node.children.each { |child| write_node(io, child, indent + 1) }
      end
    end
  end
end
