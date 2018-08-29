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

  def suggest(substring)
    node = find(substring, @root)
    return [] if node.nodes.size == 0
    node.nodes.inject([]) do |suggestions, key_value_pair|
      word = substring + key_value_pair[0].to_s
      suggestions << word if key_value_pair[1].is_word
      suggestions + suggest(word)
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

  # --- Delete ---

    def delete(word)
      unflag_word(word)
      return if assess_from_root(word)
      deleting(word)
    end

  # starts at last node for word and works back
  def deleting(word, previous = [])
    return if word.size == 0
    node = find(word, @root)
    if active_path?(node) == false
      backtrack(word, word[0..-2], previous)
    else
      node.nodes.delete(previous[-1].to_sym)
    end
  end

  def backtrack(word, prefix, previous)
    previous << word[-1]
    deleting(prefix, previous)
  end

  def assess_from_root(word)
    key = word[0].to_sym
    if active_path?(@root.nodes[key]) == false
      @root.nodes.delete(word[0].to_sym)
    end
  end

  def active_path?(node)
    a_word = node.is_word
    leads_to_words = count(node)
    a_word == false && leads_to_words == 0 ? false : true
    # false = node is useless
    # true = node is important
  end

  def unflag_word(word)
    node = find(word, @root)
    node.is_word = false
  end

end
