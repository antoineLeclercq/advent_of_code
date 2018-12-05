#!/usr/bin/env ruby

# require 'faraday'
require 'fileutils'
require 'pry-byebug'

day = ARGV[0]

day_dir = "day#{day}"
FileUtils.mkdir(day_dir) unless Dir.exist? day_dir

['problem.txt', 'input.txt', 'test_input.txt'].each do |f|
  file_path = "#{day_dir}/#{f}"
  FileUtils.touch(file_path) unless File.exist? file_path
end

boilerplate_code = <<-CODE
class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split("\\n").compact
  end

  class << self
    def run_part1_test
      result = new('./test_input.txt').run_part1
      output = (result == nil) ? 'GOOD' : "WRONG\\ngot \#{result}, expected nil"
      puts output
    end

    def run_part2_test
      result = new('./test_input.txt').run_part2
      output = (result == nil) ? 'GOOD' : "WRONG\\ngot \#{result}, expected nil"
      puts output
    end
  end

  def run_part1
  end

  def run_part2
  end
end

# Solution.run_part1_test
# Solution.run_part2_test

# p Solution.new('./input.txt').run_part1
# p Solution.new('./input.txt').run_part2
CODE
File.write("#{day_dir}/solution.rb", boilerplate_code)

# input = Faraday.get("https://adventofcode.com/2018/day/#{day}/input")
