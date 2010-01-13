module Harp
  module Formatter
    class Text < Base
      def write(io = $stdout)
        write_method_summary(io)
        io.puts('')
        write_call_tree(io)
      end

      private

      def write_header(io)
        io.puts(sprintf(
          '%-10s  %-10s  %-10s  %-15s  %-7s  %-5s  %s',
          'total',
          'self',
          'child',
          'total percent',
          'percent',
          'count',
          'call'
        ))
      end

      def write_method_summary(io)
        io.puts("=== METHOD SUMMARY ===")
        write_header(io)
        @report.methods.each do |method|
          write_node(io, method, @report.total_time)
        end
      end

      def write_call_tree(io)
        io.puts("=== CALL TREE ===")
        write_header(io)
        @report.heads.each { |head| write_node_tree(io, head, @report.total_time) }
      end

      def write_node(io, node, indent = 0)
        percent_of_total = node.time_for_percent / @report.total_time * 100
        percent = node.time_for_percent / node.parent.total_time * 100
        io.puts(sprintf(
          "%.8f  %.8f  %.8f  %15d  %7d  %5d  #{'  '*indent}%s",
          node.total_time,
          node.self_time,
          node.child_time,
          percent_of_total,
          percent,
          node.count,
          node_signature(node)
        ))
      end

      def write_node_tree(io, node, indent = 0)
        unless stop_node?(node)
          unless skip_node?(node)
            write_node(io, node, indent)
            indent += 1
          end
          node.children.each { |child| write_node_tree(io, child, indent) }
        end
      end
    end
  end
end
