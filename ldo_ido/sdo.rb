require_relative 'sudoku_graph'
require_relative 'node'

class SDO
  def initialize(sudoku, size = 9, repair_iterations = 500, wipe_iterations = 100, wipe_sets_amount = 3)
    @sudoku = sudoku
    @size = size
    @repair_iterations = repair_iterations
    @wipe_iterations = wipe_iterations
    @wipe_sets_amount = wipe_sets_amount
  end

  def valid?
    !@sudoku.nil?
  end

  def solve
    dsatur @sudoku

    puts "Conflictos iniciales: #{@sudoku.conflictive_nodes.size}"

    @wipe_iterations.times do |x|
      @sudoku.wipe @wipe_sets_amount
      dsatur @sudoku

      @sudoku = repair @sudoku

      if @sudoku.solved?
        puts "Iterations: #{x}"
        break
      end

    end

    @sudoku
  end

  private

  def dsatur(sudoku)
    total_nodes = sudoku.vertices.size
    colored_nodes = sudoku.vertices.select(&:colored?).size
    node_index = nil

    while colored_nodes < total_nodes
      max = -1

      # SDO
      vertices = sudoku.vertices.reject(&:colored?).shuffle.sort

      vertices.each_with_index do |node, i|
        sd = node.saturation_degree

        if sd >= max
          max = sd
          node_index = vertices[i]
        end

        if node_index && !node_index.colored?
          node_index.assign_first_possible_color
          colored_nodes += 1
        end
      end
    end

    sudoku
  end

  def repair(sudoku, iterations = 500)
    min = sudoku.conflictive_nodes.size
    min_s = sudoku.dup

    iterations.times do |x|
      amount_conflictive_nodes = sudoku.conflictive_nodes.size

      if amount_conflictive_nodes.zero?
        min_s = sudoku.dup
        break
      end

      if amount_conflictive_nodes < min
        min = amount_conflictive_nodes
        min_s = sudoku.dup

        puts "Bajamos los conflictos a: #{min}"
        # Si volvemos al minimo, tarda 13m 
      end

      sudoku.conflictive_nodes.each do |cn|
        sudoku.resolve_conflict cn
      end

      dsatur sudoku
    end

    min_s
  end
end
