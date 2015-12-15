class Clique
  NUMBER_NODES = 9
  attr_accessor :possible_additions, :clique, :sorted_possible_additions,
                :graph, :clique_list

  def initialize(first_vertex, graph)
    aMatrix = graph.matrix
    @possible_additions = []
    @clique = []
    @sorted_possible_additions = {} # tree map
    @clique_list = []
    @graph = graph

    clique << first_vertex
    clique_list << first_vertex

    NUMBER_NODES.times do |i|
      if i != first_vertex && aMatrix[i, first_vertex] == 1
        @possible_additions << i
        @sorted_possible_additions << graph.nodes[i] # TREE MAP
      end
    end
  end

  def add_vertex(vertex, aMatrix)
    @clique << vertex
    @clique_list << vertex
    remove_from_sorted_possible_additions graph.nodes[vertex]
    @possible_additions.delete vertex

    @possible_additions.each do |pa_vertex|
      tmp = aMatrix[pa_vertex, vertex]

      if tmp == 0
        # it.remove
        @possible_additions.delete vertex
        remove_from_sorted_possible_additions graph.nodes[pa_vertex]
      elsif tmp == 1
        # Do nothing
      else
        fail "Invalid Matrix in addVertex of Clique"
      end
    end
  end

  def remove_vertex(vertex, aMatrix)
    return unless @clique.include?(vertex)

    @clique.delete vertex
    @clique_list.remove vertex

    NUMBER_NODES.times do |i|
      unless @clique.include? i
        row = aMatrix.row(i).to_a
        adjacent_to_all = @clique.all? { |ver| row[ver] != 0 }

        if adjacent_to_all
          @possible_additions << i
          @sorted_possible_additions << @graph.nodes[i]
        end
      end
    end
  end

  def remove_from_sorted_possible_additions(node)
    @sorted_possible_additions.delete node
  end

  def compute_sorted_list
    sorted_list = []

    @possible_additions.each do |node1|
      reach = 0

      @possible_additions.each do |node2|
        reach += 1 if graph.matrix[node1, node2] == 1
      end

      sorted_list << SortedListNode.new node1, reach
    end

    sorted_list.sort
  end
end
