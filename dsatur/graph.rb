require 'matrix'
require_relative 'node'
require_relative 'constants'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class Graph
  attr_accessor :nodes, :sorted_nodes

  def initialize
    @matrix = Matrix.build(NUMBER_NODES) { 0 }
    @sorted_nodes = []
    @nodes = []

    NUMBER_NODES.times do |i|
      node = Node.new i
      @nodes << node
      @sorted_nodes << node
    end
  end

  def sort_list
    @sorted_nodes.sort!
  end

  def add_edge(sv, ev)
    @matrix[sv,ev] = 1
    @matrix[ev,sv] = 1

    get_node(sv).add_edge(ev)
    get_node(ev).add_edge(sv)
  end

  private

  def get_node(index)
    node = @nodes[index]

    if node.nil?
      node = Node.new index
      @nodes[index] = node
      @sorted_nodes[index] = node
    end

    node
  end

end
