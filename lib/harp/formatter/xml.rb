require 'nokogiri'

module Harp
  module Formatter
    class Xml < Base
      def write(io = $stdout)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.report do |report|
            report.send(:"call-tree") do |call_tree|
              @report.heads.each do |head|
                write_node_tree(call_tree, head)
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
            :class => node.class_name,
            :method => node.method,
            :total => node.total_time,
            :self => node.self_time,
            :child => node.child_time,
            :total_percent => ((node.total_time.to_f / @report.total_time.to_f) * 100).to_i,
            :percent => ((node.total_time.to_f / node.parent.total_time.to_f) * 100).to_i
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
