require 'minitest/autorun'

describe SudokuGraph do
  describe "adjacent" do
    before do
      @sudoku = SudokuGraph.new 4

      # a b | c d
      # e f | g h
      # - - - - -
      # i j | k l
      # m n | o p
    end

    describe 'adjacent vertical' do
      it "returns the adjacent vertical array of nodes" do
        node_a = @sudoku[0,0]
        node_c = @sudoku[0,2]
        node_i = @sudoku[2,0]

        expected = [[0,0], [1,0], [2,0], [3,0]]

        adjacents_a = @sudoku.vertical_for(node_a).map(&:coords)
        adjacents_c = @sudoku.vertical_for(node_c).map(&:coords)
        adjacents_i = @sudoku.vertical_for(node_i).map(&:coords)

        assert_equal expected, adjacents_a
        assert_equal expected, adjacents_i
        assert_not_equal expected, adjacents_c
      end
    end

    it "returns the adjacent horizontal array of nodes" do
      node_a = @sudoku[0,0]
      node_c = @sudoku[0,2]
      node_i = @sudoku[2,0]

      expected = [[0,0], [0,1], [0,2], [0,3]]

      adjacents_a = @sudoku.horizontal_for(node_a).map(&:coords)
      adjacents_c = @sudoku.horizontal_for(node_c).map(&:coords)
      adjacents_i = @sudoku.horizontal_for(node_i).map(&:coords)

      assert_equal expected, adjacents_a
      assert_equal expected, adjacents_c
      assert_not_equal expected, adjacents_i
    end

    it "returns the adjacent block array of nodes" do
      node_a = @sudoku[0,0]
      node_c = @sudoku[0,2]
      node_f = @sudoku[1,1]
      node_i = @sudoku[2,0]

      expected = [[0,0], [0,1], [1,0], [1,1]]

      adjacents_a = @sudoku.block_for(node_a).map(&:coords)
      adjacents_c = @sudoku.block_for(node_c).map(&:coords)
      adjacents_f = @sudoku.block_for(node_f).map(&:coords)
      adjacents_i = @sudoku.block_for(node_i).map(&:coords)

      assert_equal expected, adjacents_a
      assert_equal expected, adjacents_f
      assert_not_equal expected, adjacents_c
      assert_not_equal expected, adjacents_i
      assert_not_equal adjacents_c, adjacents_i
    end

    it "returns the all the adjacents of a node except by itself" do
      node_a = @sudoku[0,0]

      expected = [[0,0], [1,0], [2,0], [3,0]] +
                 [[0,0], [0,1], [0,2], [0,3]] +
                 [[0,0], [0,1], [1,0], [1,1]]

      expected = expected.uniq!.sort - [[0,0]]

      adjacents_a = @sudoku.adjacent(node_a).map(&:coords).sort

      assert_equal expected, adjacents_a
    end
  end
end
