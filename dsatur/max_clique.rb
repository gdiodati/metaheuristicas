require_relative 'constants'

class MaxClique
  def self.compute_clique(graph)
    g_best = Hash.new #LinkedHashSet
    puts "Computing Clique..."

    start = Time.now

    # Construct an initial Clique only based on the degrees of the nodes
    graph.sort_list
    nodes = graph.sorted_nodes
    clique = Clique.new nodes[0].value, graph
    sList = clique.compute_sorted_list

    while clique.possible_additions.size > 0
      sList.each do |s_node|
        if clique.possible_additions.include? s_node.node
          clique.add_vertex(s_node.node, graph.matrix)
        end
      end
    end

    # g_best.add_all(clique.clique)
    prev_best = clique.clique.size
    count = 0
    restarts = []

    ANNEALING_ITERATIONS.times do |i|
      if prev_best == g_best.size
        count += 1
        count = 0 if count > TOLERANCE
      else
        prev_best = g_best.size
        count = 0
      end

      # Toma dos vertices al azar y los remueve de la clique
      vertex1, vertex2 = take_two_random_vertices clique
      clique.remove_vertex v1, graph.matrix
      clique.remove_vertex v2, graph.matrix

      # Agrega vertices a la clique basado en :sorted_possible_additions
      if clique.possible_additions.size > 0
        sorted_list = clique.compute_sorted_list
        while clique.possible_additions.size > 0 do
          sorted_list.each do |node|
            if clique.possible_additions.include? node.node
              clique.add_vertex node.node, graph.matrix
            end
          end
        end
      else
        fail "QUE ONDA"
      end
    end

    # Intentamos mejorar la solucion considerando todos los vertices
    # uno a uno usando movimientos 1-OPT
    max_clique = g_best.size
    clique.clique = g_best
    clique.clique_list = []
    clique.clique_list.push *clique.clique

    while true
      flag = false
      clique.clique.each do |node|
        require 'pry'; binding.pry
        clique.remove_vertex node, graph.matrix
        sort_list = clique.compute_sorted_list

        it = sort_list.to_enum
        while clique.possible_additions.size > 0
          node = it.next
          if clique.possible_additions.include? node.node
            clique.add_vertex node.node, graph.matrix
          end
        end

        if clique.clique.size > max_clique
          max_clique = clique.clique.size
          flag = true
          break
        end
      end

      break unless flag
    end

    g_best = []
    g_best.push *clique.clique

    puts "Maximum Clique Size Found: #{g_best.size}"
    puts "Vertices in the Clique: "
    g_best.each do |node|
      puts "#{node} "
    end


    puts "\n\n #{Time.now - start} milliseconds (excluding I/O)."

    g_best
  end

  def random_restart(clique, graph, restarts)
    puts "Random Restarting..."

    rand_idx = rand NUMBER_NODES
    count = 0
    while restarts[rand_idx] == 1
      count += 1

      break if count > MAX_UNIQUE_ITERATIONS

      rand_idx = rand NUMBER_NODES
    end
    restarts[rand_idx] = 1

    clq = Clique.new rand_idx, graph
    sorted_list = clq.compute_sorted_list
    it = sorted_list.to_enum

    while clq.possible_additions.size > 0
      node = it.next
      if clq.possible_additions.include? node.node
        clq.add_vertex node.node, graph.matrix
      end
    end

    clique.clique = clq.clique
    clique.clique_list = clq.clique_list
    clique.possible_additions = clq.possible_additions
    clique.sorted_possible_additions = clq.sorted_possible_additions
  end


  private

  def take_two_random_vertices(clique)
    size = clique.clique.size
    v1 = v2 = rand size

    v2 = rand size while v1 == v2

    [clique.clique_list[v1], clique.clique_list[v2]]
  end
end
