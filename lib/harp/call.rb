module Harp
  class Call < Object
    attr_reader :clazz, :method, :children

    def initialize(clazz, method, time, allocations)
      @clazz, @method, @time, @allocations = clazz, method, time, allocations
      @children = []
    end

    def add_child(call)
      @children << call
    end

    def add_children(calls)
      calls.each { |call| add_child(call) }
    end

    def class_name
      @clazz.to_s
    end

    def to_s
      "#{class_name}##{method}"
    end

    def total_time
      @time
    end

    def self_time
      @self_time ||= total_time - child_time
    end

    def child_time
      @child_time ||= @children.inject(0.0) do |time, child|
        time + child.total_time
      end
    end

    def total_allocations
      @allocations
    end

    def self_allocations
      @self_allocations ||= total_allocations - child_allocations
    end

    def child_allocations
      @child_allocations ||= @children.inject(0) do |allocations, child|
        allocations + child.total_allocations
      end
    end
  end
end
