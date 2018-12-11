require 'pry-byebug'

class Solution
  attr_reader :inputs

  def initialize(input)
    @inputs = input.split("\n")
  end

  def run_part1
    puts "\n\n"
    puts "DATA FOR THE FIRST POINT"
    p points.points.first
    puts "\n\n"

    max = points.max_mahattan_distance
    while max > 300
      points.move
      max = points.max_mahattan_distance
    end
    while true
      puts "\n\n"
      puts "DATA FOR THE FIRST POINT"
      p points.points.first
      puts "\n\n"
      points.draw
      points.move
    end
  end

  def run_part2
    #<Point:0x00007fb3c2120c28 @x=-41214, @y=-10223, @x_velocity=4, @y_velocity=1>
    #<Point:0x00007fb3c2120c28 @x=206, @y=132, @x_velocity=4, @y_velocity=1>
  end

  def points
    @points ||= Points.new(inputs.map { |i| Point.new(*PointParser.new(i).parse) })
  end
end

class Points
  attr_reader :points

  def initialize(points)
    @points = points
  end

  def move
    max = max_mahattan_distance
    points.each do |point|
      multiplier = max / 1000 + 1
      point.move(multiplier)
    end
  end

  def pairs
    @pairs ||= points.combination(2)
  end

  def max_mahattan_distance
    pairs.map { |pair| manhattan_distance(pair.first, pair.last) }.max
  end

  def manhattan_distance(p1, p2)
    (p1.x - p2.x).abs + (p1.y - p2.y).abs
  end

  def draw
    puts
    puts board.map {|row| row.join('') }.join("\n")
    puts
  end

  def board
    b = (0..max_y).map { |_| ['.'] * (max_x) }
    points.each do |point|
      b[point.y - min_y][point.x - min_x] = '#'
    end
    b
  end

  def min_x
    points.min_by(&:x).x
  end

  def min_y
    points.min_by(&:y).y
  end

  def max_y
    points.max_by(&:y).y - min_y
  end

  def max_x
    points.max_by(&:x).x - min_x
  end
end

class PointParser
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def parse
    input.scan(/-?\d+/).map(&:to_i)
  end
end

class Point
  attr_accessor :x, :y
  attr_reader :x_velocity, :y_velocity

  def initialize(x, y, x_velocity, y_velocity)
    @x = x
    @y = y
    @x_velocity = x_velocity
    @y_velocity = y_velocity
  end

  def move(multiplier)
    self.x += (x_velocity *  multiplier)
    self.y += (y_velocity * multiplier)
  end
end

describe Points do
  it 'move' do
    point = Point.new(1, 1, 1, -1)
    point.move(1)
    expect(point.x).to eq(2)
    expect(point.y).to eq(0)
  end
end

describe PointParser do
  it 'parse' do
    parser = PointParser.new('position=<1, -1> velocity=< 1,  -1>')
    expect(parser.parse).to eq([1, -1, 1, -1])
  end
end

describe Solution do
  xit 'run_part1' do
    s = Solution.new(File.read('./test_input.txt').strip)
    expect(s.run_part1).to eq(nil)
  end

  xit 'run_part2' do
    s = Solution.new(File.read('./test_input.txt').strip)
    expect(s.run_part2).to eq(nil)
  end

  it 'points' do
    s = Solution.new(File.read('./test_input.txt').strip)
    expect(s.points.points.size).to eq(31)
    expect(s.points.points.first.x).to eq(9)
    expect(s.points.points.first.y).to eq(1)
    s.points.move
    expect(s.points.points.first.x).to eq(9)
    expect(s.points.points.first.y).to eq(3)
  end
end

p Solution.new(File.read('./input.txt').strip).run_part1
# p Solution.new(File.read('./input.txt').strip).run_part2
