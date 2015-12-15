class SortedListNode
  include Comparable

  attr_accessor :node, :reach

  def initialize(node, reach)
    @node = node
    @reach = reach
  end

  def <=>(sortedNode)
    @reach <=> sortedNode.reach
  end
end
