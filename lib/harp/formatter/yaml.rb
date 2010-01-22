module Harp
  module Formatter
    class Yaml < Base
      def write(io = $stdout)
        YAML.dump(add_node_to_collection(@report.root).first, io)
      end

      private

      def add_node_to_collection(node, collection = [])
        if stop_node?(node)
          return collection
        end
        child_collection = collection
        unless skip_node?(node)
          collection << {
            :data => {
              :name => node_signature(node),
              :total_time => node.total_time,
              :self_time => node.self_time,
              :child_time => node.child_time,
              :percent_time_of_parent => node.percent_time_of_parent.to_i,
              :percent_time_of_total => node.percent_time_of_total.to_i,
              :aggregate_percent_time_of_total => node.aggregate_percent_time_of_total.to_i,
              :total_allocations => node.total_allocations,
              :self_allocations => node.self_allocations,
              :child_allocations => node.child_allocations,
              :percent_allocations_of_parent => node.percent_allocations_of_parent.to_i,
              :percent_allocations_of_total => node.percent_allocations_of_total.to_i,
              :aggregate_percent_allocations_of_total => node.aggregate_percent_allocations_of_total.to_i,
              :count => node.count,
              :aggregate_count => node.aggregate_count
            },
            :children => child_collection = []
          }
        end
        node.children.each { |child| add_node_to_collection(child, child_collection) }
        collection
      end
    end
  end
end
