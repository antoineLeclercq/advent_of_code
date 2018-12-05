class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split("\n").compact
  end

  def run
    counts = @inputs.map do |letters|
      lc = letters_count(letters)
      { 2 => (lc.key(2) && 1) || 0, 3 => (lc.key(3) && 1) || 0 }
    end.reduce({2 => 0, 3 => 0}) do |res, c|
      res[2] += c[2]
      res[3] += c[3]
      res
    end

    counts[2] * counts[3]
  end

  def letters_count(s)
    count = {}
    s.each_char do |c|
      count[c] ||= 0
      count[c] += 1
    end

    count
  end
end

result = (Solution.new('./test_input.txt').run == 12) ? 'GOOD' : 'WRONG'

puts result
p Solution.new('./input.txt').run
