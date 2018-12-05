class Solution
  def run
    input = File.read("./input.txt")
    lines = input.split("\n")
    lines.compact.map(&:to_i).reduce(:+)
  end
end

p Solution.new.run
