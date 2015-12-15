class Node
  attr_accessor :row, :col, :color, :graph

  def initialize(graph, row, col)
    @graph = graph
    @row = row
    @col = col
    @color = nil
  end

  def coords
    [row, col]
  end

  def degree
    @graph.degree self
  end

  def saturation_degree
    adjacent_colors.size
  end

  def colored?
    !!@color
  end

  def conflict?
    colored? && @color > graph.size
  end

  def adjacent_colors
    @graph.adjacent(self).map!(&:color).uniq.compact
  end

  def assign_first_possible_color
    k = graph.total_nodes

    possible_colors = (1..k).to_a - adjacent_colors

    @color = possible_colors.empty? ? rand(k) + 1 : possible_colors.first
  end

  def inspect
    "<Node [#{row},#{col}] color='#{@color}'>"
  end

  def to_s
    inspect
  end
end
