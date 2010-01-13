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


report = Harp::Report.new.run do
  begin
    fib(0)
    call_raise_exception
  rescue
  end
  fib(5)
end
formatter = Harp::Formatter::Text.new(report)
formatter.filter_by_signature(nil, 'call_raise_exception')
formatter.write
