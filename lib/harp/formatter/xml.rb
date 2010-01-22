require 'nokogiri'

module Harp
  module Formatter
    class Xml < Base
      def write(io = $stdout)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.report do |report|
            report.send(:"call-tree") do |call_tree|
              @report.root.children.each do |call_node|
                write_node_tree(call_tree, call_node)
              end
            end
          end
        end
        io.write(builder.to_xml)
      end

      private

      def write_node_tree(xml, node)
        unless stop_node?(node)
          xml.call(
            :name => node.to_s,
            :total => node.total_time,
            :self => node.self_time,
            :child => node.child_time,
            :"percent-time-of-parent" => node.percent_time_of_parent.to_i,
            :"percent-time-of-total" => node.percent_time_of_total.to_i,
            :"aggregate-percent-time-of-total" => node.aggregate_percent_time_of_total.to_i,
            :"percent-allocations-of-parent" => node.percent_allocations_of_parent.to_i,
            :"percent-allocations-of-total" => node.percent_allocations_of_total.to_i,
            :"aggregate-percent-allocations-of-total" => node.aggregate_percent_allocations_of_total.to_i
          ) do |call_xml|
            node.children.each do |child_node|
              write_node_tree(call_xml, child_node)
            end
          end
        end
      end
    end
  end
end
