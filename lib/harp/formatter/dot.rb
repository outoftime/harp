require 'dotr'

module Harp
  module Formatter
    class Dot < Base
      def initialize(report)
        super
        @seen_nodes = Hash.new { |h, k| h[k] = 0 }
      end

      def write(io = $stdout)
        graph = DotR::Digraph.new
        graph.node("ROOT", :label => "Root") do |root|
          @report.heads.each do |head|
            write_node_tree(head, @report, root, graph)
          end
        end
        io.write(graph.to_s)
      end

      private

      def write_node_tree(node, parent_node, parent_dot_node, graph)
        percent = (node.total_time / parent_node.total_time) * 100
        total_percent = (node.total_time / @report.total_time) * 100
        allocation_percent =
          if parent_node.total_allocations > 0
            (node.total_allocations.to_f / parent_node.total_allocations.to_f) * 100
          else
            0
          end
        total_allocation_percent = (node.total_allocations.to_f / @report.total_allocations.to_f) * 100
        unless stop_node?(node)
          if skip_node?(node) #XXX DRY
            node.children.each do |child_node|
              write_node_tree(child_node, parent_node, parent_dot_node, graph)
            end
          else
            label = [
              node_signature(node),
              sprintf("%.5f total time", node.total_time),
              sprintf("%.5f self time", node.self_time),
              sprintf("%.5f child time", node.child_time),
              "#{percent.to_i}% / #{total_percent.to_i}%",
              '',
              sprintf("%5d total allocations", node.total_allocations), 
              sprintf("%5d self allocations", node.self_allocations),
              sprintf("%5d child allocations", node.child_allocations),
              "#{allocation_percent.to_i}% / #{total_allocation_percent.to_i}%"
            ].join('\n')
            graph.node(node_name(node), :label => label, :shape => 'box') do |dot_node|
              parent_dot_node.connection(dot_node.name, :label => node.count)
              node.children.each do |child_node|
                write_node_tree(child_node, node, dot_node, graph)
              end
            end
          end
        end
      end

      def node_name(node)
        "#{node.to_s}-#{@seen_nodes[node.to_s] += 1}"
      end
    end
  end
end
