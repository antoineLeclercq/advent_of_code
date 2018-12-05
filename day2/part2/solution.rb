class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split("\n").compact
  end

  def run
    id1, id2 = find_correct_ids
    same_chars(id1, id2)
  end

  def find_correct_ids
    inputs.each_with_index do |id, i|
      ((i + 1)...inputs.size).to_a.each do |j|
        return [id, inputs[j]] if correct_ids?(id, inputs[j])
      end
    end
  end

  def same_chars(id1, id2)
    chars = ''
    id1.chars.each_index do |i|
      chars << id1[i] if id1[i] == id2[i]
    end
    chars
  end

  def ids_diff(id1, id2)
    diff = 0
    id1.chars.each_index do |i|
      diff += 1 if id1[i] != id2[i]
    end
    diff
  end

  def correct_ids?(id1, id2)
    ids_diff(id1, id2) == 1
  end
end

test = Solution.new('./test_input.txt').run
result = (test == 'fgij') ? 'GOOD' : "WRONG\nexpected: fgij\ngot: #{test}"

puts result
puts Solution.new('./input.txt').run
