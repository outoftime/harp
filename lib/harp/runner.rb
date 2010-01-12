module Harp
  module Runner
    class <<self
      def run
        start
        yield
        stop
      end
    end
  end
end

require File.join(File.dirname(__FILE__), '..', '..', 'ext', 'harp', 'runner')
