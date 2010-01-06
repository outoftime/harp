require 'harp'
include Harp
def multiply(a, b)
  val = 0
  b.times { val += a }
end

start
multiply(5, 2)
stop
