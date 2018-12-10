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
require 'pry-byebug'

class Solution
  attr_reader :inputs

  def initialize(path)
    @inputs = File.read(path).split("\\n").compact
  end

  def run_part1
  end

  def run_part2
  end
end

describe Solution do
  it 'run_part1' do
    s = Solution.new('./test_input.txt')
    expect(s.run_part1).to eq(nil)
  end

  it 'run_part2' do
    s = Solution.new('./test_input.txt')
    expect(s.run_part2).to eq(nil)
  end
end

# p Solution.new('./input.txt').run_part1
# p Solution.new('./input.txt').run_part2
CODE
File.write("#{day_dir}/solution.rb", boilerplate_code)

# input = Faraday.get("https://adventofcode.com/2018/day/#{day}/input")
