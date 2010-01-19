require 'rubygems'
require 'ruby-debug'
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

def call_raise_exception
  raise_exception
end

def raise_exception
  raise
end

def output_tree(calls, indent = 0)
  calls.each do |call|
    puts "#{'  '*indent}#{call.to_s}"
    output_tree(call.children, indent + 1)
  end
end

i = 0

def alloc_something
  []
end

report = Harp::Report.new.run do
  alloc_something
  alloc_something
end
formatter = Harp::Formatter::Dot.new(report)
formatter.filter_by_signature(nil, 'call_raise_exception')
formatter.write
