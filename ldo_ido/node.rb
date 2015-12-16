class Node
  attr_accessor :row, :col, :color, :graph

  def initialize(graph, row, col)
    @graph = graph
    @row = row
    @col = col
    @color = nil
    @fixed = false
  end

  def coords
    [row, col]
  end

  def <=>(other)
    other.saturation_degree <=> saturation_degree
  end

  def degree
    @graph.degree self
  end

  def saturation_degree
    adjacent_colors.size
  end

  def fix_color(color)
    @color = color
    @fixed = true
  end

  def color=(color)
    @color = color unless @fixed
  end

  def colored?
    !!@color
  end

  def conflict?
    colored? && !@fixed && @color > graph.size
  end

  def fixed?
    @fixed
  end

  def adjacent_colors
    graph.adjacent(self).map!(&:color).uniq.compact
  end

  def assign_first_possible_color
    k = graph.total_nodes

    possible_colors = (1..k).to_a - adjacent_colors

    @color = possible_colors.empty? ? rand(k) + 100 : possible_colors.first
  end

  def inspect
    is_fixed = @fixed ? " FIXED" : ''

    "<Node [#{row},#{col}] color='#{@color}' dsatur=#{saturation_degree}#{is_fixed}>"
  end

  def to_s
    inspect
  end
end
