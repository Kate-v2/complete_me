require 'pry'
require './lib/node'

class CompleteMe
  attr_reader :root

  def initialize
    @root = Node.new

  end

  def insert(word)
    node = @root

    inserting(word, node)

  end

  def inserting(word, node)
    return if word.size == 0

    key = word[0].to_sym
    substring = word[1..word.length]

    node.exists?(key) ? node = node.nodes[key] : node = node.add_node(key)

    node.is_word = true if word.length == 1

    inserting(substring, node)
  end

  def populate(input)

    words = to_array(input)

    words.each do |word|
      insert(word)
    end

  end

  def to_array(input)
    case input
    when String
      input.split("\n")
    when Array
      input
    else
      nil
    end

  end

  def count(node = @root)
    #binding.pry
    return 0 if node.nodes.size == 0

    sum = 0
    node.nodes.values.each do |node|
          #binding.pry
      if node.is_word
        sum += 1
      end
      sum += count(node)
    end
    sum
  end

end



test_library = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle", "zebra"]


complete_me = CompleteMe.new()

dictionary = File.read("/usr/share/dict/words")
#complete_me.populate(test_library)
complete_me.populate(dictionary)
#binding.pry
p complete_me.count
# complete_me.insert("pizza")
# complete_me.insert("pizzaria")
# binding.pry
