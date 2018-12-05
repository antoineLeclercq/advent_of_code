class Solution
  def run
    input = File.read("./input.txt")
    lines = input.split("\n")
    frequencies = lines.map(&:to_i).compact

    seen = {}
    frequency = 0
    loop do
      frequency = frequencies.reduce(frequency) do |f, n|
        return f if seen[f]
        seen[f] = true
        f + n
      end
    end
  end
end

p Solution.new.run
