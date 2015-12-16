require 'matrix'

class SudokuGraph
  attr_reader :size

  def initialize(size = 4)
    @limit = Math.sqrt(size).to_i

    fail "Size must be a square number" unless @limit**2 == size

    @size = size
    @matrix = Matrix.build(size) { |row, col| Node.new self, row, col }
  end

  def self.from_file(path, size = 9)
    sudoku = new size

    File.open(path).each_with_index do |line, row|
      line.split(' ').each_with_index do |color, col|
        sudoku[row, col].fix_color(color.to_i) unless color.to_i.zero?
      end
    end

    sudoku
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

  def resolve_conflict(node)
    v = vertical_for node
    h = horizontal_for node
    b = block_for node

    intersections = [
      [possible_colors_from(v, b) - fixed_colors(h), h],
      [possible_colors_from(h, b) - fixed_colors(v), v],
      [possible_colors_from(v, h) - fixed_colors(b), b]
    ]

    colors, conflictive_adjacents = intersections.find { |n| !n.first.empty? }

    node.color = colors.first
    conflictive_adjacents -= [node]

    conflict_node = conflictive_adjacents.detect { |n| n.color == node.color }
    conflictive_adjacents.each{|n| n.color = nil}

    self
  end

  def possible_colors_from(array1, array2)
    colors = ->(nodes) { nodes.map(&:color) }

    intersection = colors.call(array1) & colors.call(array2)

    (1..size).to_a - intersection
  end

  def wipe(amount = 3)
    to_wipe = []

    to_wipe += @matrix.row_vectors.select { |nodes| sum_colors(nodes) != 45 }
    to_wipe += @matrix.column_vectors.select { |nodes| sum_colors(nodes) != 45 }

    to_wipe.shuffle.take(amount).each {|ns| wipe_nodes ns }
    # wipe_nodes to_wipe.sample
    # wipe_nodes to_wipe.sample

    self
  end

  def wipe_nodes(nodes)
    nodes.each {|n| n.color = nil}

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
    horizonal_separator = "-" + "-".rjust(4) * (@size + @limit -2) + "\n"

    str = "<SudokuGraph:#{@size} conflictive:#{conflictive_nodes.size}> \n"

    @matrix.row_vectors.each_with_index do |row, idx|
      print_row = row.to_a.map(&:color).map! { |e| e.to_s.rjust(3) }
      sum = sum_colors(row).to_s.rjust 3

      str << horizonal_separator if idx % @limit == 0 && idx > 0

      extra = 0
      (0..row.size).step(@limit) do |insert_index|
        print_row.insert insert_index + extra, '|'
        extra += 1
      end

      str << print_row.join(" ") + "> #{sum}\n"
    end

    str << horizonal_separator

    print_row = @matrix.column_vectors.map do |col|
      sum_colors(col).to_s.rjust 3
    end

    extra = 0
    (0..@size).step(@limit) do |insert_index|
      print_row.insert insert_index + extra, '|'
      extra += 1
    end

    str << print_row.join(" ") + "\n"

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

  def solved?
    conflict_nodes = conflictive_nodes.size.zero?

    rows_and_columns = @matrix.row_vectors + @matrix.column_vectors
    valid_sums = rows_and_columns.all? { |nodes| sum_colors(nodes) == 45 }

    conflict_nodes && valid_sums
  end

  private

  def fixed_colors(nodes)
    nodes.select(&:fixed?).map(&:color)
  end

  def sum_colors(nodes)
    nodes.to_a.map(&:color).compact.reduce(:+)
  end


end

