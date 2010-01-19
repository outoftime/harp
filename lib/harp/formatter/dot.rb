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
        write_node_tree(@report.root, nil, graph)
        io.write(graph.to_s)
      end

      private

      def write_node_tree(node, parent_dot_node, graph)
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
              "#{node.percent_time_of_parent.to_i}% / #{node.percent_time_of_total.to_i}%",
              '',
              sprintf("%5d total allocations", node.total_allocations), 
              sprintf("%5d self allocations", node.self_allocations),
              sprintf("%5d child allocations", node.child_allocations),
              "#{node.percent_allocations_of_parent.to_i}% / #{node.percent_allocations_of_total.to_i}%"
            ].join('\n')
            graph.node(node_name(node), :label => label, :shape => 'box') do |dot_node|
              if parent_dot_node
                parent_dot_node.connection(dot_node.name, :label => node.count)
              end
              node.children.each do |child_node|
                write_node_tree(child_node, dot_node, graph)
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
