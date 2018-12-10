require 'pry-byebug'

class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split(' ').compact.map(&:to_i)
  end

  def run_part1
    root = NodesParser.new(inputs).parse
    metadata_total(root)
  end

  def run_part2
    root = NodesParser.new(inputs).parse
    root.value
  end

  def metadata_total(node)
    return node.metadata_total if node.children.empty?

    node.metadata_total + node.children.reduce(0) do |res, n|
      res + metadata_total(n)
    end
  end
end

class NodesParser
  attr_reader :inputs

  def initialize(inputs)
    @inputs = inputs
  end

  def parse
    return if inputs.empty?

    children_count = inputs.shift
    metadata_count = inputs.shift
    node = Node.new
    (0...children_count).each do |i|
      node.children << parse
    end
    (0...metadata_count).each do |i|
      node.metadata << inputs.shift
    end

    node
  end

  def parse_node
    Node.new(children_count, metadata_count)
  end
end

class Node
  attr_reader :metadata, :children

  def initialize
    @metadata = []
    @children = []
  end

  def metadata_total
    metadata.reduce(&:+)
  end

  def value
    return metadata_total if children.empty?

    metadata.reduce(0) do |res, i|
      child = children[i - 1]
      next res if child.nil? || i == 0
      res + child.value
    end
  end
end

describe Solution do
  it 'run_part1' do
    s = Solution.new('./test_input.txt')
    expect(s.run_part1).to eq(138)
  end

  it 'run_part2' do
    s = Solution.new('./test_input.txt')
    expect(s.run_part2).to eq(66)
  end
end

# p Solution.new('./input.txt').run_part1
p Solution.new('./input.txt').run_part2
