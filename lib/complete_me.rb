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
    # base case, if there are no more nodes
    return 0 if node.nodes.size == 0
    # sum up everything => block will return sum
    node.nodes.values.inject(0) do |sum, node|
      # add one if the node is a word
      sum += 1 if node.is_word
      # add to the count of everything below it in Trie
      sum += count(node)
    end
  end

  def suggest(substring)
    node = find(substring, @root)
    return [] if node.nodes.size == 0
    node.nodes.inject([]) do |suggestions, key_value_pair|
      word = substring + key_value_pair[0].to_s
      suggestions << word if key_value_pair[1].is_word
      suggestions + suggest(word)
    end
  end


  # -----------------------------
  # Select(prefix, word)


  def select(prefix, word)
    # prefix - add a :word => count hash  +=
    # find_word(word) ---> return end node
    # word_node --> weight +=
  end


  def find(string, node)
    return node if string.size == 0
    key = string[0].to_sym
    substring = string[1..string.size]
    node = node.nodes[key]
    find(substring, node)
  end

  def match_prefix
    # TO DO - node.rb - add instance var for frequently selected
    # TO DO - node.rb - add instance var for weight (incremented at is_word node)
    # TO DO - add node_tests
  end



end

#
# test_library = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle", "zebra"]
#
#
complete_me = CompleteMe.new()

dictionary = File.read("/usr/share/dict/words")
complete_me.populate(dictionary)

suggestions = complete_me.suggest("piz")
p suggestions[0..4]

#binding.pry
