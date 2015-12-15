class Node
  attr_accessor :value, :color, :next, :previous, :degree_sat, :color_count,
                :possible_colors, :list, :degree

  def initialize(value)
    @value = value
    @list = []
    @possible_colors = []
    @degree = 0
    @degree_sat = 0
    @color_count = 0
    @color = :uncolored
  end

  def ==(aNode)
    aNode.value == value
  end

  def add_edge(edge_value)
    @list << edge_value
    @degree += 1
  end

  def to_s
    "<Node value: #{@value} degree: #{@degree}>"
  end

  def color_node(col)
    @color = col
  end

  def valid_color?(graph, color)
    list.all? { |ev| graph.nodes[ev] != color }
  end

  def compute_degree_sat(graph)
    @degree_sat = 0

    list.each do |ev|
      if graph.nodes[ev].color != :uncolored
        @degree_sat += 1
      end
    end
  end

  def next_color
    return reset_color_count if @color_count == @possible_colors.size

    @color_count += 1

    @possible_colors[@color_count - 1]
  end

  def reset_color_count
    @color_count = 0
    @color = :uncolored
  end

  def compute_possible_colors(graph, k)
    @possible_colors = []

    (1..k).each do |i|
      available = @list.all? do |ev|
        graph.nodes[ev].color != i
      end

      @possible_colors << i if available
    end
  end

  def find_conflicting_nodes(graph)
    conflicts = []

    @list.each do |ev|
      node = graph.nodes[ev]

      conflicts << node if node.color == @color
    end

    conflicts
  end

  def hash_code
    #algun hash
  end
end
