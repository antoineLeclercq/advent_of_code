require 'pry-byebug'

class Solution
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def run_part1
    Game.new(*parse).play
  end

  def run_part2
    pc, lmv = parse
    Game.new(pc, lmv * 100).play
  end

  def parse
    input.scan(/\d+/).map(&:to_i)
  end
end

class Game
  attr_reader :players_count, :last_marble_value

  def initialize(players_count, last_marble_value)
    @players_count = players_count
    @last_marble_value = last_marble_value
  end

  def players
    @players ||= (0...players_count).map { |p| Player.new }
  end

  def marbles
    @marbles ||= (0..last_marble_value).map { |m| Marble.new(m) }
  end

  def play
    current = marbles.first
    current.next = current
    current.prev = current

    (1...marbles.count).each do |i|
      marble = marbles[i]
      player = players[i % players.count]

      if i < 2
        marble.next = current
        marble.prev = current
        current.next = marble
        current.prev = marble
        current = marble
      elsif marble.value % 23 == 0
        player.marbles << marble
        target = current
        7.times { |_| target = target.prev }
        remove(target)
        player.marbles << target
        current = target.next
      else
        marble.next = current.next.next
        marble.prev = current.next
        marble.next.prev = marble
        current.next.next = marble
        current = marble
      end
    end

    players.max_by(&:score).score
  end

  def remove(marble)
    marble.prev.next = marble.next
    marble.next.prev = marble.prev
  end
end

# class Cicle
#   attr_accessor :start

#   def initialize(start)
#     @start = start
#   end
# end

class Marble
  attr_accessor :next, :prev
  attr_reader :value

  def initialize(value)
    @value = value
  end
end

class Player
  attr_reader :marbles

  def initialize
    @marbles = []
  end

  def score
    marbles.reduce(0) { |res, m| res + m.value }
  end
end

describe Solution do
  it 'run_part1' do
    s = Solution.new('10 players; last marble is worth 1618 points')
    expect(s.run_part1).to eq(8317)
  end

  it 'run_part1 2' do
    s = Solution.new('13 players; last marble is worth 7999 points')
    expect(s.run_part1).to eq(146373)
  end

  it 'run_part1 3' do
    s = Solution.new('17 players; last marble is worth 1104 points')
    expect(s.run_part1).to eq(2764)
  end

  it 'run_part1 4' do
    s = Solution.new('21 players; last marble is worth 6111 points')
    expect(s.run_part1).to eq(54718)
  end

  it 'run_part1 5' do
    s = Solution.new('30 players; last marble is worth 5807 points')
    expect(s.run_part1).to eq(37305)
  end

  it 'run_part1 6' do
    s = Solution.new('9 players; last marble is worth 25 points')
    expect(s.run_part1).to eq(32)
  end

  xit 'run_part2' do
    s = Solution.new('./test_input.txt')
    expect(s.run_part2).to eq(nil)
  end
end

p Solution.new(File.read('./input.txt').strip).run_part1
p Solution.new(File.read('./input.txt').strip).run_part2
