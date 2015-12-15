require_relative 'sudoku_graph'
require_relative 'node'

def main(graph)
  colored_nodes = graph.vertices.select(&:colored?).size
  total_nodes = graph.vertices.size
  node_index = nil
  index = -1

  while colored_nodes < total_nodes
    max = -1

    vertices = graph.vertices.shuffle
    vertices.each_with_index do |node, i|
      unless node.colored?
        sd = node.saturation_degree

        if sd > max
          max = sd
          index = i
          node_index = vertices[i]
        end
      end

      if node_index && !node_index.colored?
        node_index.assign_first_possible_color
        colored_nodes += 1
      end
    end
  end

  graph
end

def reset_conflictive_nodes(sudoku)
  sudoku.conflictive_nodes.each do |cn|
    sudoku.reset_colors cn
  end
end

sudoku = SudokuGraph.new 9

main sudoku

puts sudoku

puts "recalculando"

min = 10000
max = 0
min_s, max_s = nil
100.times do |x|
  reset_conflictive_nodes sudoku
  main sudoku

  if sudoku.conflictive_nodes.size > max
    max = sudoku.conflictive_nodes.size
    max_s = sudoku.dup
  end

  if sudoku.conflictive_nodes.size < min
    min = sudoku.conflictive_nodes.size
    min_s = sudoku.dup

    puts "*" * 80
    puts sudoku
  end
end

require 'pry'; binding.pry
