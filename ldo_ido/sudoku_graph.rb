require 'matrix'

class SudokuGraph
  attr_reader :size

  def initialize(size = 4)
    @limit = Math.sqrt(size).to_i

    fail "Size must be a square number" unless @limit**2 == size

    @size = size
    @matrix = Matrix.build(size) { |row, col| Node.new self, row, col }
  end

  def [](r,c)
    @matrix[r,c]
  end

  def adjacent(node)
    (horizontal_for(node) + vertical_for(node) + block_for(node)).uniq - [node]
  end

  def conflictive_nodes
    vertices.select(&:conflict?)
  end

  def horizontal_for(node)
    @matrix.row(node.row).to_a
  end

  def vertical_for(node)
    @matrix.column(node.col).to_a
  end

  def block_for(node)
    start_row = node.row - (node.row % @limit)
    start_col = node.col - (node.col % @limit)

    block = []

    @limit.times do |row|
      @limit.times do |col|
        block << @matrix[row + start_row, col + start_col]
      end
    end

    block
  end

  def reset_colors(node)
    node.color = rand(@size) + 1
    adjacent(node).each { |n| n.color = nil }
    self
  end

  # Given it is a Sudoku graph, all the nodes has the same degree
  def degree(node)
    2 * (@size - 1) + (@limit - 1) ** 2
  end

  def vertices
    @matrix.row_vectors.map(&:to_a).flatten
  end

  def total_nodes
    @size * @size
  end

  def inspect
    horizonal_separator = "- " * (@size + @limit + 1) + "\n"

    str = "<SudokuGraph:#{@size} conflictive:#{conflictive_nodes.size}> \n"

    @matrix.row_vectors.each_with_index do |row, idx|
      print_row = row.to_a.map(&:color)

      str << horizonal_separator if idx % @limit == 0 && idx > 0

      extra = 0
      (0..row.size).step(@limit) do |insert_index|
        print_row.insert insert_index + extra, '|'
        extra += 1
      end

      str << print_row.join(" ") + "\n"
    end

    str
  end

  def to_s
    inspect
  end

  def dup
    dup_sudoku = SudokuGraph.new @size
    dup_sudoku.vertices.each do |node|
      node.color = self[*node.coords].color
    end

    dup_sudoku
  end
end

