require 'minitest/autorun'

describe Node do
  describe "creation" do
    it "must initialize it" do
      node = Node.new 1

      assert_equal 1, node.value
      assert_equal :uncolored, node.color
      assert_equal [], node.list
      assert_equal [], node.possible_colors
      assert_equal 0, node.degree
      assert_equal 0, node.color_count
    end
  end

  it "compares equality by value" do
    node1 = Node.new 1
    node2 = Node.new 2
    node3 = Node.new 1

    assert_equal node1, node3
    assert_not_equal node1, node2
    assert_not_equal node2, node3
  end

  describe "coloring" do
    before do
      @node = Node.new 1

      @node.color_node 91
    end

    it "must color a node" do
      assert_equal 91, @node.color
    end

    it "must reset color count and node color" do
      @node.reset_color_count

      assert_equal 0, @node.color_count
      assert_equal :uncolored, @node.color
    end
  end

  describe "add_edge" do
    before do
      @node = Node.new 1
    end

    it "must increase degree and add to the list" do
      assert @node.list.empty?
      assert_equal 0, @node.degree

      @node.add_edge 8

      deny @node.list.empty?
      assert_equal 1, @node.degree
    end
  end
end
