require 'pry-byebug'

class Solution
  attr_reader :input

  def initialize(path)
    @input = File.read(path).strip
  end

  class << self
    def run_part1_test
      result = new('./test_input.txt').run_part1
      output = (result == 10) ? 'GOOD' : "WRONG got #{result}, expected 10"
      puts output
    end

    def run_part2_test
      result = new('./test_input.txt').run_part2
      output = (result == 4) ? 'GOOD' : "WRONG got #{result}, expected 4"
      puts output
    end
  end

  def run_part1
    remove_destructive_sections(input.dup).size
  end

  def run_part2
    [*('a'..'z')].map do |letter|
      s = input.dup
      s.gsub!(/#{letter}|#{letter.capitalize}/, '')
      res = remove_destructive_sections(s)
      res.size
    end.min
  end

  def remove_destructive_sections(string)
    left = 0
    right = 1
    destroying = false
    size = string.size
    while right < size
      if same_type_oppisite_oplarity?(string[left], string[right])
        destroying = true
        if left == 0 || right == size - 1
          left, right, size = destroy_section_of_units(string, left, right, destroying)
          destroying = false
        else
          left -= 1
          right += 1
        end
      else
        if destroying
          destroying = false
          left, right, size = destroy_section_of_units(string, left, right, destroying)
        else
          left += 1
          right += 1
        end
      end
    end

    string
  end

  def same_type_oppisite_oplarity?(c1, c2)
    c1 != c2 && c1.downcase == c2.downcase
  end

  def destroy_section_of_units(string, left, right, destroying)
    if left == 0 && destroying
      string.slice!(left..right)
      left = 0
      right = 1
    elsif right == string.size - 1 && destroying
      string.slice!(left..right)
      right = string.size
    else
      string.slice!(left + 1..right - 1)
      left += 1
      right = left + 1
    end

    return left, right, string.size
  end
end

Solution.run_part1_test
Solution.run_part2_test

# p Solution.new('./input.txt').run_part1
p Solution.new('./input.txt').run_part2
