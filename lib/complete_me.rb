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


    # REFACTOR
    # -- RECURSIVE --
    # If I do it recursively, I can pass back falses, until I hit true and change that node
    # **************************************************
    #  DETECT & FIND ENUMERABLES
    # https://ruby-doc.org/core-2.2.3/Enumerable.html#method-i-detect

    # .detect will find the first node where my conditions are true

    # **************************************************


    # ** LOGIC ? ****************************************
    # if it's a word keep it
    # IT CAN BE a word without it being the deepest that can be deleted

    # it can be a word and go deeper
    # it can have no following words and be a word

    # it cannot be important if it's not a word and points to no words
    # **************************************************

  def delete(word)
    unflag_word(word)
    return if assess_from_root(word)  # .each cannot capture a dead end at root
    hash = delete_instructions(word.chars)
    delete_map(hash)
  end

  # RECURSIVE rewrite
  # ----------------------------
    def del(word)
      # Need to unflag word, but only want to run it once
      unflag_word(word)
      return if assess_from_root(word)  # .each cannot capture a dead end at root
      deleting(word)
    end

  # work backwards from word's node
  def deleting(word, previous = [])
    return if word.size == 0
    node = find(word, @root)
    prefix = word[0..-2]
    delete_logic(word, prefix, previous, node)
    # if node_impact?(node) == false
    #   previous << word[-1]
    #   deleting(prefix, previous) # moves back a node
    # else
    #   key = previous[-1].to_sym
    #   node.nodes.delete(key)
    # end
  end

  def delete_logic(word, prefix, previous, node)
    if node_impact?(node) == false
      previous << word[-1]
      deleting(prefix, previous) # moves back a node
    else
      key = previous[-1].to_sym
      node.nodes.delete(key)
    end
  end
  # -----------------------------------



  # detect # the first node that points to a false
  def delete_instructions(letters)
    index = 0
    letters.each { |l|
      prefix = letters[0..index].join
      current_node = find(prefix, @root)
      next_index = index + 1
      next_letter = letters[next_index]
      next_node = find(next_letter, current_node)
      if node_impact?(next_node) == false
        hash = {prefix: prefix, node: current_node, :delete => next_letter}
        # binding.pry
        return hash
      end
      index += 1
    }
  end

  def delete_map(hash)
    prefix = hash[:prefix]
    node = hash[:node]
    key = hash[:delete].to_sym
    node.nodes.delete(key)
  end



  def assess_from_root(word)
    key = word[0].to_sym
    if node_impact?(@root.nodes[key]) == false
      @root.nodes.delete(word[0].to_sym)
    end
  end

  def node_impact?(node)
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
