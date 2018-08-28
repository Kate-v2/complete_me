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

  # --- Count ---

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

  # --- Suggest ---

  def suggest(substring)
    node = find(substring, @root)
    unweighted = unweighted_suggest(substring, node)
    sorted_hashes = sort_hashes_by_frequency(node)
    sorted_words = get_words_from_sorted_hashes(sorted_hashes)
    binding.pry
    (sorted_words + unweighted).uniq
  end

  def unweighted_suggest(substring, node)
    node = find(substring, @root)
    # base case
    return [] if node.nodes.size == 0
      # add up arrays, recursively (breaking up node into char symbol and next nodes)
      node.nodes.inject([]) do |suggestions, (char_sym, node)|
      # create this word by adding the symbol of this node to the substring
      word = substring + char_sym.to_s
      # if this new 'word' is flagged a word, add to suggestions
      suggestions << word if node.is_word
      # add array of suggestions of everything below it
      suggestions + unweighted_suggest(word, node)
    end
  end

  def sort_hashes_by_frequency(node)
    node.frequent.sort_by do |word, count|
      count
    end.reverse
  end

  def get_words_from_sorted_hashes(sorted_hashes)
    sorted_hashes.map do |hash_array|
      hash_array[0].to_s
    end
  end




  # --- Select ---

  def select(prefix, word)
    match_prefix(prefix, word)
    add_weight(word)
  end

  def find(string, node)
    return node if string.size == 0
    key = string[0].to_sym
    substring = string[1..string.size]
    node = node.nodes[key]
    find(substring, node)
  end

  def match_prefix(prefix, word)
    node = find(prefix, @root)
    hash = node.frequent
    key = word.to_sym
    hash[key] == nil ? hash[key] = 1 : hash[key] += 1
  end

  def add_weight(word)
    node = find(word, @root)
    node.weight += 1
  end

end

#
# test_library = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle", "zebra"]
#
#
# complete_me = CompleteMe.new()
#
# dictionary = File.read("/usr/share/dict/words")
# complete_me.populate(dictionary)
#
# suggestions = complete_me.suggest("piz")

#binding.pry
