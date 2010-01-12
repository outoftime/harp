require File.join(File.dirname(__FILE__), 'report', 'node')

module Harp
  class Report
    attr_reader :head

    def add_call_tree(root)
      @head = Node.new(root)
    end

    def run(&block)
      add_call_tree(Harp::Runner.run(&block))
      self
    end
  end
end
