require 'pry'

require_relative 'test_helper'   # require test_helper first

require "minitest/autorun"
require "minitest/pride"

require './lib/node.rb'

class NodeTest < Minitest::Test

  def test_it_exists
    node = Node.new
    assert_instance_of Node, node
  end

  def test_it_gets_attributes
    node = Node.new
    empty_hash = {}
    assert_equal false, node.is_word
    assert_equal empty_hash, node.nodes
    assert_equal 0, node.weight
    assert_equal empty_hash, node.frequent
  end

  def test_it_tests_if_nodes_already_exist
    node = Node.new
    # Nodes are values of keys
    node.nodes[:a] = "I Exist"

    yes_node = node.exists?(:a)
    no_node = node.exists?(:z)

    assert_equal true, yes_node
    assert_equal false, no_node
  end

  def test_it_can_add_a_node
    node = Node.new
    assert_equal 0, node.nodes.count
    node.add_node(:a)
    assert_equal 1, node.nodes.count
  end
end
