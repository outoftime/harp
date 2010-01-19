require File.join(File.dirname(__FILE__), 'report', 'method_aggregator')
require File.join(File.dirname(__FILE__), 'report', 'method_summary')
require File.join(File.dirname(__FILE__), 'report', 'node')
require File.join(File.dirname(__FILE__), 'report', 'root_node')
require File.join(File.dirname(__FILE__), 'report', 'call_node')

module Harp
  class Report
    attr_reader :root

    def initialize
      @root = RootNode.new(self)
    end

    def run(&block)
      Harp::Runner.run(&block).each do |call|
        @root.add_child_call(call)
      end
      self
    end

    def total_time
      @root.total_time
    end

    def total_allocations
      @root.total_allocations
    end
  end
end
