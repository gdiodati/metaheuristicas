require 'minitest/autorun'
require_relative '../sudoku_graph'

describe Node do
  before do
    @sudoku = SudokuGraph.new 4
  end

  it "returns node coords" do
    assert_equal [0,0], @sudoku[0,0].coords
    assert_equal [1,0], @sudoku[1,0].coords
  end

  it "returns node's degree" do
    node = @sudoku[0,0]
    assert_equal 7, node.degree

    node = SudokuGraph.new(9)[0,0]
    assert_equal 20, node.degree
  end

  it "returns if its colored or not" do
    node = @sudoku[0,0]
    deny node.colored?

    node.color = 1
    assert node.colored?
  end

  it "returns a boolean conflict if is a conflictive color" do
    node = @sudoku[0,0]
    deny node.conflict?

    node.color = 100
    assert node.conflict?
  end
end
