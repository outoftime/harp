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
      # It's weird, but it looks like every method call increments the object
      # allocation counter, even when it's quite clear no allocation is
      # happening. I've checked and it doesn't look like the allocation is a
      # side-effect of anything happening in the Harp event hook, so this
      # admittedly ugly hack is the best I can come up with to get the right
      # number of allocations.
      # @total_allocations ||= @allocations - tree_size
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

    def tree_size
      @tree_size ||= @children.inject(0) do |tree_size, child|
        tree_size + child.tree_size + 1
      end
    end
  end
end
