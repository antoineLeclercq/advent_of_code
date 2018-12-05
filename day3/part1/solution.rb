class Solution
  attr_reader :rectangles

  def initialize(path)
    inputs = File.read(path).split("\n").compact
    @rectangles = inputs.map { |e| Rectangle.new(e) }
  end

  def run
    rectangles.reduce({}) do |res, r|
      r.all_coords.each do |coord|
        res[coord] ||= 0
        res[coord] += 1
      end
      res
    end.select { |k,v| v >= 2 }.size
  end
end

class Rectangle
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def id
    raw.scan(/#\d+/).first
  end

  def x
    raw.scan(/@ (\d+),/).flatten.first.to_i + 1
  end

  def y
    raw.scan(/@ \d+,(\d+)/).flatten.first.to_i + 1
  end

  def width
    raw.scan(/: (\d+)x/).flatten.first.to_i
  end

  def height
    raw.scan(/: \d+x(\d+)/).flatten.first.to_i
  end

  def top_left_coords
    { x: x, y: y }
  end

  def bottom_left_coords
    { x: x, y: y + height }
  end

  def top_right_coords
    { x: x + width, y: y }
  end

  def bottom_right_coords
    { x: x + width, y: y + height }
  end

  def all_coords
    return @all_coords if @all_coords

    res = []
    (x...x + width).each do |x_coord|
      (y...y + height).each do |y_coord|
        res << { x: x_coord, y: y_coord }
      end
    end

    @all_coords = res
  end
end

result = Solution.new('./test_input.txt').run
output = (result == 4) ? 'GOOD' : "WRONG\ngot #{result}, expected 4"

puts output
p Solution.new('./input.txt').run
