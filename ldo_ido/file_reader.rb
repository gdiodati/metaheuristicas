require_relative 'sudoku_graph'

module FileReader
  def self.from_regular_file(path, size)
    sudoku = SudokuGraph.new size

    File.open(path).each_with_index do |line, row|
      line.split(' ').each_with_index do |color, col|
        sudoku[row, col].fix_color(color.to_i) unless color.to_i.zero?
      end
    end

    sudoku
  end

  def self.from_dots_file(path, size)
    sudoku = SudokuGraph.new size

    str = File.read(path)

    str.gsub('.','0').split('').each_with_index do |color, idx|
      sudoku.vertices[idx].fix_color(color.to_i) unless color.to_i.zero?
    end

    sudoku
  end
end
