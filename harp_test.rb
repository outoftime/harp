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

def output_tree(tree, indent = 0)
  puts "#{'  ' * indent}#{tree.clazz}##{tree.method} (#{tree.time})"
  tree.children.each { |child| output_tree(child, indent + 1) }
end

Harp::Runner.start
fib(5)
output_tree(Harp::Runner.stop)


