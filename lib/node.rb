class Node
  attr_accessor :is_word, :nodes, :frequent, :weight

  def initialize
    @is_word = false
    @nodes = {}
    @frequent = {}
    @weight = 0
  end

  def exists?(key)
    @nodes.has_key?(key)
  end

  def add_node(key)
    node = Node.new
    @nodes[key] = node
  end

end
