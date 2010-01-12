module Harp
  class Call < Object
    attr_reader :clazz, :method, :time, :children

    def initialize(clazz, method, time)
      @clazz, @method, @time = clazz, method, time
      @children = []
    end

    def add_child(call)
      @children << call
    end
  end
end
