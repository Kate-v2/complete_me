class Node
  attr_accessor :is_word, :nodes

  def initialize
    @is_word = false
    @nodes = {}
  end

  def exists?(key)
    @nodes.has_key?(key)
  end

  def add_node(key)
    node = Node.new
    @nodes[key] = node
  end

end
