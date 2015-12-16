require_relative 'sudoku_graph'
require_relative 'node'

def dsatur(sudoku)
  total_nodes = sudoku.vertices.size
  colored_nodes = sudoku.vertices.select(&:colored?).size
  node_index = nil

  while colored_nodes < total_nodes
    max = -1

    # SDO
    vertices = sudoku.vertices.reject(&:colored?).shuffle.sort

    vertices.each_with_index do |node, i|
      # unless node.colored?
        sd = node.saturation_degree

        if sd >= max
          max = sd
          node_index = vertices[i]
        end
      # end

      if node_index && !node_index.colored?
        node_index.assign_first_possible_color
        colored_nodes += 1
      end
    end
  end

  sudoku
end

def repair(sudoku, count = 500)
  min = sudoku.conflictive_nodes.size
  min_s = sudoku.dup

  count.times do |x|
    amount_conflictive_nodes = sudoku.conflictive_nodes.size

    if amount_conflictive_nodes.zero?
      min_s = sudoku.dup
      break
    end

    sudoku.conflictive_nodes.each do |cn|
      sudoku.resolve_conflict cn
    end

    dsatur sudoku

    if amount_conflictive_nodes < min
      min = amount_conflictive_nodes
      min_s = sudoku.dup

      puts "Bajamos los conflictos a: #{min}"
    end

  end

  sudoku = min_s
end

# 'input/s08a.txt'
a = SudokuGraph.from_file(ARGV[0]);

dsatur a
puts "Conflictos iniciales: #{a.conflictive_nodes.size}"

100.times do |x|
  a = repair a

  if a.solved?
    puts "Iterations: #{x}"
    break
  end

  a.wipe
  dsatur a
end

puts "Solucion Final"
puts a
