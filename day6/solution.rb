require 'pry-byebug'
class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split("\n").compact
  end

  class << self
    def run_part1_test
      result = new('./test_input.txt').run_part1
      output = (result == 17) ? 'GOOD' : "WRONG\ngot #{result}, expected 17"
      puts output
    end

    def run_part2_test
      result = new('./test_input.txt').run_part2
      output = (result == 16) ? 'GOOD' : "WRONG\ngot #{result}, expected 16"
      puts output
    end
  end

  def run_part1
    place_destinations
    determine_closest_for_all
    ids = destinations.destinations_with_finite_area(grid).map(&:id)
    grid.count_by_id.select { |id,count| ids.include? id }.values.max
  end

  def run_part2
    place_destinations
    determine_closest_for_all
    grid.all.select do |loc|
      sum = destinations.reduce(0) do |res, d|
        loc2 = grid.get(d.x, d.y)
        res += loc.manhattan_distance(loc2)
      end
      sum < 10000
    end.size
  end

  def destinations
    return @destinations if @destinations
    dests = inputs.each_with_index.map do |input, i|
      x, y = input.split(', ')
      Destination.new(x: x.to_i, y: y.to_i, id: i)
    end
    @destinations = Destinations.new(dests)
  end

  def grid
    return @grid if @grid
    width = destinations.max_x + 2
    height = destinations.max_y + 2
    @grid = Grid.new(width, height)
  end

  def place_destinations
    destinations.each do |d|
      location = Location.new(d.x, d.y)
      location.is_a_desination = true
      location.closest_destination = d.id
      grid.set(location)
    end
  end

  def determine_closest_for_all
    grid.all.each do |loc|
      dest_by_dist = {}
      destinations.each do |d|
        loc2 = grid.get(d.x, d.y)
        dist = loc.manhattan_distance(loc2)
        dest_by_dist[dist] ||= []
        dest_by_dist[dist] << d
      end
      min_dist = dest_by_dist.keys.min
      next if dest_by_dist[min_dist].size > 1
      loc.closest_destination = dest_by_dist[min_dist].first.id
    end
  end
end

class Grid
  attr_reader :grid, :width, :height

  def initialize(width, height)
    @height = height
    @width = width
    build(width, height)
  end

  def build(width, height)
    @grid ||= Array.new(height) do |y|
      Array.new(width) do |x|
        loc = Location.new(x, y)
      end
    end
  end

  def set(loc)
    grid[loc.y][loc.x] = loc
  end

  def get(x, y)
    grid[y][x]
  end

  def raw
    grid.map { |row| row.map { |loc| loc.closest_destination } }
  end

  def all
    grid.flatten
  end

  def on_edge?(id)
    on_first_row?(id) || on_last_row?(id) || on_first_col?(id) || on_last_col?(id)
  end

  def on_first_col?(id)
    (0...height).any? { |y| get(0, y).closest_destination == id }
  end

  def on_last_col?(id)
    (0...height).any? { |y| get(width - 1, y).closest_destination == id }
  end

  def on_first_row?(id)
    (0...width).any? { |x| get(x, 0).closest_destination == id }
  end

  def on_last_row?(id)
    (0...width).any? { |x| get(x, height - 1).closest_destination == id }
  end

  def count_by_id
    all.group_by(&:closest_destination).each_with_object({}) do |(k, v), res|
      res[k] = v.count
    end
  end
end

class Location
  attr_accessor :x, :y, :closest_destination, :is_a_desination

  def initialize(x, y)
    @x = x
    @y = y
    @closest_destination = nil
    @is_a_desination = false
  end

  def manhattan_distance(other_loc)
    (x - other_loc.x).abs + (y - other_loc.y).abs
  end
end

class Destinations
  include Enumerable

  attr_reader :destinations

  def initialize(destinations)
    @destinations = destinations
  end

  def destinations_with_finite_area(grid)
    destinations.reject { |d| d.infinite_area?(grid) }
  end

  def max_x
    destinations.max_by(&:x).x
  end

  def max_y
    destinations.max_by(&:y).y
  end

  def each(&block)
    destinations.each(&block)
  end

  def [](index)
    destinations[index]
  end

  def size
    destinations.size
  end
end

class Destination
  attr_reader :x, :y, :id

  def initialize(x:, y:, id:)
    @x = x
    @y = y
    @id = id
  end

  def infinite_area?(grid)
    grid.on_edge?(id)
  end

  # def all_directions?(dirs)
  #   directions.all? { |d| dirs.include?(d) }
  # end

  # def all_diagonal_directions?(dirs)
  #   diagonal_directions.all? { |dir| dirs.include?(dir) }
  # end

  # def all_normal_directions?(dirs)
  #   directions.all? { |dir| dirs.include?(dir) }
  # end

  # def locate_all(destinations)
  #   destinations.map { |d| locate_area(d) }.compact.uniq
  # end

  # def locate_area(other_dest)
  #   locate_diagonal(other_dest) || locate_straight(other_dest)
  # end

  # def locate_diagonal(other_dest)
  #   diagonal_directions.find do |dir|
  #     other_dest.y.send(diagonal_direction_to_sign[dir[0]], y) &&
  #       other_dest.x.send(diagonal_direction_to_sign[dir[1]], x)
  #   end
  # end

  # def locate_straight(other_dest)
  #   if other_dest.x == x
  #     if other_dest.y > y
  #       :bottom
  #     elsif other_dest.y < y
  #       :top
  #     end
  #   elsif other_dest.y == y
  #     if other_dest.x > x
  #       :right
  #     elsif other_dest.x < x
  #       :left
  #     end
  #   end
  # end

  # def diagonal_direction_to_sign
  #   { top: :<, bottom: :>, left: :<, right: :> }
  # end

  # def diagonal_directions
  #   @directions ||= [[:top, :left], [:top, :right], [:bottom, :left], [:bottom, :right]]
  # end

  # def directions
  #   [:top, :bottom, :left, :right]
  # end
end

describe Destination do
  # it 'locate_area' do
  #   d1 = Destination.new(x:1, y:1, id: 1)
  #   d2 = Destination.new(x:1, y:6, id: 2)
  #   d3 = Destination.new(x:8, y:3, id: 3)
  #   d4 = Destination.new(x:3, y:4, id: 4)
  #   d5 = Destination.new(x:5, y:5, id: 5)
  #   d6 = Destination.new(x:8, y:9, id: 6)

  #   expect(d1.locate_area(d2)).to eq(:bottom)
  #   expect(d1.locate_area(d3)).to eq([:bottom, :right])
  #   expect(d1.locate_area(d4)).to eq([:bottom, :right])
  #   expect(d1.locate_area(d5)).to eq([:bottom, :right])
  #   expect(d1.locate_area(d6)).to eq([:bottom, :right])
  # end

  # it 'locate_area' do
  #   d1 = Destination.new(x:1, y:1, id: 1)
  #   d2 = Destination.new(x:1, y:6, id: 2)
  #   d3 = Destination.new(x:8, y:3, id: 3)
  #   d4 = Destination.new(x:3, y:4, id: 4)
  #   d5 = Destination.new(x:5, y:5, id: 5)
  #   d6 = Destination.new(x:8, y:9, id: 6)

  #   expect(d5.locate_area(d1)).to eq([:top, :left])
  #   expect(d5.locate_area(d2)).to eq([:bottom, :left])
  #   expect(d5.locate_area(d3)).to eq([:top, :right])
  #   expect(d5.locate_area(d4)).to eq([:top, :left])
  #   expect(d5.locate_area(d6)).to eq([:bottom, :right])
  # end

  # it 'locate_all' do
  #   d1 = Destination.new(x:1, y:1, id: 1)
  #   d2 = Destination.new(x:1, y:6, id: 2)
  #   d3 = Destination.new(x:8, y:3, id: 3)
  #   d4 = Destination.new(x:3, y:4, id: 4)
  #   d5 = Destination.new(x:5, y:5, id: 5)
  #   d6 = Destination.new(x:8, y:9, id: 6)

  #   expect(d1.locate_all([d2, d3, d4, d5, d6])).to eq([:bottom, [:bottom, :right]])
  # end

  # it 'all_directions?' do
  #   d1 = Destination.new(x:1, y:1, id: 1)
  #   d2 = Destination.new(x:1, y:6, id: 2)
  #   d3 = Destination.new(x:8, y:3, id: 3)
  #   d4 = Destination.new(x:3, y:4, id: 4)
  #   d5 = Destination.new(x:5, y:5, id: 5)
  #   d6 = Destination.new(x:8, y:9, id: 6)

  #   expect(d1.all_directions?([:bottom, [:bottom, :right]])).to eq(false)
  # end

  it 'infinite_area?' do
    s = Solution.new('./test_input.txt')

    s.place_destinations
    s.determine_closest_for_all

    expect(s.destinations[0].infinite_area?(s.grid)).to eq(true)
    expect(s.destinations[3].infinite_area?(s.grid)).to eq(false)
    expect(s.destinations[4].infinite_area?(s.grid)).to eq(false)
  end
end

describe Destinations do
  it 'destinations_with_finite_area' do
    s = Solution.new('./test_input.txt')

    s.place_destinations
    s.determine_closest_for_all

    expect(s.destinations.destinations_with_finite_area(s.grid)).to eq([s.destinations[3], s.destinations[4]])
  end
end

describe Grid do
  it 'grid' do
    grid = Grid.new(10, 10)

    expect(grid.grid.size).to eq(10)
    expect(grid.grid.first.size).to eq(10)
  end

  it 'set' do
    location = Location.new(4, 5)
    grid = Grid.new(10, 10)
    grid.set(location)

    expect(grid.get(4, 5)).to eq(location)
  end

  it 'raw' do
    locations = Array.new(4) do |y|
      Array.new(4) do |x|
        loc = Location.new(x, y)
        loc.closest_destination = y
        loc
      end
    end
    result = [
      [0,0,0,0],
      [1,1,1,1],
      [2,2,2,2],
      [3,3,3,3]
    ]

    grid = Grid.new(4, 4)
    locations.each { |row| row.each { |l| grid.set(l) } }

    expect(grid.raw).to eq(result)
  end
end

describe Solution do
  it 'destinations' do
    s = Solution.new('./test_input.txt')

    expect(s.destinations.size).to eq(6)
    expect(s.destinations.first.id).to eq(0)
    expect(s.destinations.first.x).to eq(1)
    expect(s.destinations.first.y).to eq(1)
  end

  it 'place_destinations' do
    s = Solution.new('./test_input.txt')

    s.place_destinations
    expect(s.grid.get(1, 1).is_a_desination).to eq(true)
    expect(s.grid.get(1, 1).closest_destination).to eq(0)
  end

  it 'determine_closest_for_all' do
    s = Solution.new('./test_input.txt')
    result = [
      [0,0,0,0,0,nil,2,2,2,2],
      [0,0,0,0,0,nil,2,2,2,2],
      [0,0,0,3,3,4,2,2,2,2],
      [0,0,3,3,3,4,2,2,2,2],
      [nil,nil,3,3,3,4,4,2,2,2],
      [1,1,nil,3,4,4,4,4,2,2],
      [1,1,1,nil,4,4,4,4,nil,nil],
      [1,1,1,nil,4,4,4,5,5,5],
      [1,1,1,nil,4,4,5,5,5,5],
      [1,1,1,nil,5,5,5,5,5,5],
      [1,1,1,nil,5,5,5,5,5,5],
    ]

    s.determine_closest_for_all
    actual = s.grid.raw
    expect(actual).to eq(result)
  end
end

describe Location do
  it 'manhattan distance' do
    loc1 = Location.new(5, 10)
    loc2 = Location.new(2, 3)

    expect(loc1.manhattan_distance(loc2)).to eq(10)
    expect(loc1.manhattan_distance(loc2)).to eq(loc2.manhattan_distance(loc1))
  end
end

# Solution.run_part1_test
# Solution.run_part2_test

p Solution.new('./input.txt').run_part1
p Solution.new('./input.txt').run_part2
