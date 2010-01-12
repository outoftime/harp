require 'lib/harp'

def fib(n)
  if n == 0
    0
  elsif n == 1
    1
  else
    fib(n - 1) + fib(n - 2)
  end
end

def output_tree(node, indent = 0)
end

report = Harp::Report.new.run do
  fib(5)
end
Harp::Formatter::Text.new(report).write
