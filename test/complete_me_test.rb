require 'pry'

require 'minitest/autorun'
require 'minitest/pride'

require './lib/complete_me'
require './lib/node'



class CompleteMeTest < Minitest::Test

  def test_it_exists
    assert_instance_of CompleteMe, CompleteMe.new
  end

  def test_it_gets_attributes
    node = Node.new
    complete = CompleteMe.new
    actual = {}
    assert_equal false, complete.root.is_word
    assert_equal actual, complete.root.nodes
  end

  def test_it_can_insert_a_word
    complete = CompleteMe.new
    actual = complete.insert("cat")

    # Move through nodes via their pointer hash
    nodes1 = complete.root.nodes
    nodes2 = nodes1[:c].nodes
    nodes3 = nodes2[:a].nodes

    assert_equal [:c], nodes1.keys
    assert_equal [:a], nodes2.keys
    assert_equal [:t], nodes3.keys
    assert_equal true, nodes3[:t].is_word
  end

  def test_it_can_insert_words_recursively
    complete = CompleteMe.new

    # -- Create all new nodes --
    complete.inserting("cat", complete.root)
    # Create and move through nodes via their pointer hash
    new_nodes_nodes1 = complete.root.nodes
    new_nodes_nodes2 = new_nodes_nodes1[:c].nodes
    new_nodes_nodes3 = new_nodes_nodes2[:a].nodes

    assert_equal [:c], new_nodes_nodes1.keys
    assert_equal [:a], new_nodes_nodes2.keys
    assert_equal [:t], new_nodes_nodes3.keys
    assert_equal true, new_nodes_nodes3[:t].is_word

    # -- Iteract with mixed existing nodes --
    complete.inserting("catch", complete.root)
    # Assess nodes, possibly create, and move through trie
    mixed_nodes_nodes1 = complete.root.nodes
    mixed_nodes_nodes2 = mixed_nodes_nodes1[:c].nodes
    mixed_nodes_nodes3 = mixed_nodes_nodes2[:a].nodes
    mixed_nodes_nodes4 = mixed_nodes_nodes3[:t].nodes
    mixed_nodes_nodes5 = mixed_nodes_nodes4[:c].nodes

    assert_equal [:c], mixed_nodes_nodes1.keys
    assert_equal [:a], mixed_nodes_nodes2.keys
    assert_equal [:t], mixed_nodes_nodes3.keys
    assert_equal [:c], mixed_nodes_nodes4.keys
    assert_equal [:h], mixed_nodes_nodes5.keys
    assert_equal true, mixed_nodes_nodes5[:h].is_word

    # Assert cat is still a word
    assert_equal true, mixed_nodes_nodes3[:t].is_word
    # Assert all nodes are not word flagged
    assert_equal false, mixed_nodes_nodes1[:c].is_word
  end

  def test_it_can_populate_from_line_separated_list
    list = "cat\ncatch"
    complete = CompleteMe.new
    complete.populate(list)
    # -- Move through nodes --
    mixed_nodes_nodes1 = complete.root.nodes
    mixed_nodes_nodes2 = mixed_nodes_nodes1[:c].nodes
    mixed_nodes_nodes3 = mixed_nodes_nodes2[:a].nodes
    mixed_nodes_nodes4 = mixed_nodes_nodes3[:t].nodes
    mixed_nodes_nodes5 = mixed_nodes_nodes4[:c].nodes
    # -- Testing the last word --
    assert_equal [:c], mixed_nodes_nodes1.keys
    assert_equal [:a], mixed_nodes_nodes2.keys
    assert_equal [:t], mixed_nodes_nodes3.keys
    assert_equal [:c], mixed_nodes_nodes4.keys
    assert_equal [:h], mixed_nodes_nodes5.keys
    assert_equal true, mixed_nodes_nodes5[:h].is_word
    # -- Testing the first word --
    assert_equal true, mixed_nodes_nodes3[:t].is_word
  end

  def test_it_can_convert_a_string_to_an_array
    list = "cat\ncatch"
    complete = CompleteMe.new
    assert_equal ["cat", "catch"], complete.to_array(list)
    # switch functionality to handle adding words from an array
    list_already_array = ["cat", "catch"]
    assert_equal ["cat", "catch"], complete.to_array(list_already_array)
  end


   def test_it_can_count
    # -- Test with small array --
    complete_me_1 = CompleteMe.new()
    test_array = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle", "zebra"]
    complete_me_1.populate(test_array)
    assert_equal 6, complete_me_1.count

    # -- Test with whole dictionary (a string) --
    complete_me_2 = CompleteMe.new()
    dictionary = File.read("/usr/share/dict/words")
    complete_me_2.populate(dictionary)
    assert_equal 235886, complete_me_2.count
  end


  #  ---------------------------------------------
  # select

  def test_it_can_select_a_word
    complete = CompleteMe.new

    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # No selections yet
    assert_equal "ca", [node_1.nodes.keys, node_2.nodes.keys].join
    assert_equal 0, node_6.weight
    # assert_equal nil , node_3.frequent[:catch]
    assert_nil node_3.frequent[:catch]

    complete.select("ca", "catch")
    assert_equal 1, node_6.weight
    assert_equal 1 , node_3.frequent[:catch]

    complete.select("ca", "catch")
    assert_equal 2, node_6.weight
    assert_equal 2 , node_3.frequent[:catch]
  end

  def test_it_can_find_the_end_node_of_a_word
    complete = CompleteMe.new

    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    assert_equal node_4, complete.find("cat", node_1)
  end


  def test_if_it_can_suggest
    complete_me = CompleteMe.new()
    dictionary = File.read("/usr/share/dict/words")
    complete_me.populate(dictionary)
    expected = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle"], complete_me.suggest("piz")
  end


  def test_it_can_match_a_prefix_with_a_frequently_selected_word
    complete = CompleteMe.new

    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # No selections yet
    assert_equal "ca", [node_1.nodes.keys, node_2.nodes.keys].join
    assert_nil node_3.frequent[:catch]

    complete.select("ca", "catch")
    assert_equal 1 , node_3.frequent[:catch]

    complete.select("ca", "catch")
    assert_equal 2 , node_3.frequent[:catch]
  end

  def test_it_can_add_a_weight_to_a_word_when_selected
    complete = CompleteMe.new

    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # No selections yet
    assert_equal "ca", [node_1.nodes.keys, node_2.nodes.keys].join
    assert_equal 0, node_6.weight

    complete.select("ca", "catch")
    assert_equal 1, node_6.weight

    complete.select("ca", "catch")
    assert_equal 2, node_6.weight
  end

  # --- Delete ---
  def test_it_can_delete_a_word
    complete = CompleteMe.new
    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # -- Before --
    assert_equal node_5, node_4.nodes[:c]
    assert_equal node_5, node_5
    assert_equal node_6, node_6

    complete.delete("catch")
    # -- After --
    # still exists
    assert_equal node_2.nodes[:a], node_3
    # earliest useless node is deleted (via :c)
    assert_nil node_1.nodes[:c].nodes[:a].nodes[:t].nodes[:c]
  end

  def test_it_can_delete_a_word
    complete = CompleteMe.new
    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # -- Before --
    assert_equal node_5, node_4.nodes[:c]
    assert_equal node_5, node_5
    assert_equal node_6, node_6

    complete.del("catch")
    # -- After --
    # still exists
    assert_equal node_2.nodes[:a], node_3
    # earliest useless node is deleted (via :c)
    assert_nil node_1.nodes[:c].nodes[:a].nodes[:t].nodes[:c]
  end

  def test_it_can_give_deletion_instructions
    skip
    complete = CompleteMe.new
    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # letters = "catch".chars
    # binding.pry
    complete.delete_instructions(["c", "a", "t", "c", "h"])
    binding.pry

    hash = {prefix: "cat", node: node_4, :delete => "c"}
    assert_equal hash, complete.delete_instructions(letters)


  end








  def test_it_can_unflag_a_word
    complete = CompleteMe.new
    # -- add "cat" & "catch" to trie, manually --
    node_1 = complete.root   # root
    node_2 = Node.new   # via :c
    node_3 = Node.new   # via :a
    node_4 = Node.new   # via :t  --> is_word
    node_5 = Node.new   # via :c
    node_6 = Node.new   # via :h  --> is_word

    node_1.nodes[:c] = node_2
    node_2.nodes[:a] = node_3
    node_3.nodes[:t] = node_4
    node_4.is_word = true
    node_4.nodes[:c] = node_5
    node_5.nodes[:h] = node_6
    node_6.is_word = true

    # -- before --
    assert_equal true, node_4.is_word
    assert_equal true, node_6.is_word
    # -- after --
    complete.unflag_word("cat")
    assert_equal false, node_4.is_word
    assert_equal true, node_6.is_word
  end


end
