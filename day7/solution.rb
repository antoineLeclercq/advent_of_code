require 'pry-byebug'

$duration = 60
$workers_count = 5

class Solution
  attr_reader :inputs, :parser

  def initialize(path)
    @inputs = File.read(path).split("\n").compact
    @parser = StepParser.new(inputs)
  end

  class << self
    def run_part1_test

      result = new('./test_input.txt').run_part1
      output = (result == 'CABDFE') ? 'GOOD' : "WRONG\ngot #{result}, expected CABDFE"
      puts output
    end

    def run_part2_test
      # 63 + 66 + 59 + 63

      $duration = 0
      $workers_count = 2
      result = new('./test_input.txt').run_part2
      output = (result == 15) ? 'GOOD' : "WRONG\ngot #{result}, expected 15"
      puts output
    end
  end

  def run_part1
    Workflow.new(parsed_steps).run
  end

  def run_part2
    Workflow.new(parsed_steps).total_duration
  end

  def parsed_steps
    @parsed_steps ||= parser.parse
  end
end

class StepParser
  attr_reader :inputs, :component

  def initialize(inputs)
    @inputs = inputs
  end

  def parse
    inputs.each_with_object({}) do |i, res|
      step_value = step_value(i)
      parent_step_value = parent_step_value(i)

      res[step_value] = res[step_value] || Step.new(value: step_value)
      res[parent_step_value] = res[parent_step_value] || Step.new(value: parent_step_value)

      res[step_value].parents << res[parent_step_value]
      res[parent_step_value].children << res[step_value]
    end.values
  end

  def step_value(input)
    input.scan(/before step ([A-Z]) can begin/).flatten.first
  end

  def parent_step_value(input)
    input.scan(/^Step ([A-Z])/).flatten.first
  end
end

class Step
  attr_accessor :processed, :processing
  attr_reader :value, :parents, :children

  def initialize(value:, parents: [], children: [])
    @value = value
    @parents = parents
    @children = children
  end

  def ==(step)
    return false unless value == step.value
    parents.each_with_index do |p, i|
      return false unless p.value == step.parents[i].value
    end
    children.each_with_index do |c, i|
      return false unless c.value == step.children[i].value
    end
    true
  end

  def processed?
    @processed
  end

  def processing?
    @processing
  end

  def ready?
    parents.map(&:processed?).all? && !processed? && !processing?
  end

  def duration
    res = {}
    ('A'..'Z').each_with_index do |l, i|
      res[l] = $duration + i + 1
    end
    res[value]
  end
end

class Workflow
  attr_reader :steps, :order, :workers

  def initialize(steps)
    @steps = steps
    @order = ''
    @workers = (0...$workers_count).map { |_| Worker.new }
  end

  def run
    return order if order.size == steps.count
    process(ready_steps.first)
    run
  end

  def total_duration
    time = 0
    while !ready_steps.empty? || workers.any?(&:working?)
      workers.select(&:idle?).each do |worker|
        break if ready_steps.empty?
        worker.start(ready_steps.first)
      end

      workers.select(&:working?).each do |worker|
        worker.working_one_second
      end

      time += 1
    end
    time
  end

  def ready_steps
    steps.select(&:ready?).sort_by(&:value)
  end

  def process(step)
    order << step.value
    step.processed = true
  end
end

class Worker
  attr_accessor :current_step, :timer, :working
  attr_reader :steps

  def initialize
    @steps = []
    @timer = 0
    @working = false
  end

  def start(step)
    self.current_step = step
    self.steps << current_step
    self.working = true
    current_step.processing = true
  end

  def working_one_second
    self.timer += 1
    if current_step.duration == timer
      self.working = false
      current_step.processing = false
      current_step.processed = true
      self.timer = 0
    end
  end

  def working?
    @working
  end

  def idle?
    !working
  end
end

describe StepParser do
  it 'step_value' do
    parser = StepParser.new([])
    expect(parser.step_value('Step C must be finished before step A can begin.')).to eq('A')
  end

  it 'parent_step_value' do
    parser = StepParser.new([])
    expect(parser.parent_step_value('Step C must be finished before step A can begin.')).to eq('C')
  end

  it 'parse' do
    parser = StepParser.new(['Step C must be finished before step A can begin.'])
    step = Step.new(value: 'A')
    parent_step = Step.new(value: 'C', children: [step])
    step.parents << parent_step

    expect(step.parents.first.value).to eq('C')
    expect(parent_step.children.first.value).to eq('A')
    expect(parent_step.parents).to eq([])
    expect(parser.parse).to eq([step, parent_step])
  end

  it 'parse2' do
    parser = StepParser.new(['Step C must be finished before step A can begin.'])
    step = Step.new(value: 'A')
    parent_step = Step.new(value: 'C', children: [step])
    step.parents << parent_step

    expect(step.parents.first.value).to eq('C')
    expect(parent_step.children.first.value).to eq('A')
    expect(parent_step.parents).to eq([])
    expect(parser.parse).to eq([step, parent_step])
  end
end

describe Step do
  it 'duration' do
    expect(Step.new(value: 'A').duration).to eq(61)
    expect(Step.new(value: 'Z').duration).to eq(86)
  end
end

describe Workflow do
  let(:inputs) do
    [
      'Step C must be finished before step A can begin.',
      'Step C must be finished before step F can begin.',
      'Step A must be finished before step B can begin.',
      'Step A must be finished before step D can begin.',
      'Step B must be finished before step E can begin.',
      'Step D must be finished before step E can begin.',
      'Step F must be finished before step E can begin.',
      'Step G must be finished before step A can begin.'
    ]
  end
  let(:steps) do
    StepParser.new(inputs).parse
  end

  it 'order' do
    expect(Workflow.new(steps).run).to eq('CFGABDE')
  end

  it 'order1' do
    inputs = [
      'Step A must be finished before step B can begin.',
      'Step B must be finished before step C can begin.',
      'Step C must be finished before step D can begin.',
      'Step D must be finished before step E can begin.'
    ]
    parsed_steps = StepParser.new(inputs).parse

    expect(Workflow.new(parsed_steps).run).to eq('ABCDE')
  end

  it 'order2' do
    inputs = [
      'Step E must be finished before step D can begin.',
      'Step D must be finished before step C can begin.',
      'Step C must be finished before step B can begin.',
      'Step B must be finished before step A can begin.'
    ]

    parsed_steps = StepParser.new(inputs).parse

    expect(Workflow.new(parsed_steps).run).to eq('EDCBA')
  end

  it 'order3' do
    inputs = [
      'Step A must be finished before step B can begin.',
      'Step D must be finished before step B can begin.',
      'Step C must be finished before step B can begin.',
      'Step B must be finished before step E can begin.',
      'Step B must be finished before step F can begin.',
      'Step B must be finished before step G can begin.',
      'Step C must be finished before step I can begin.',
      'Step I must be finished before step J can begin.',
      'Step J must be finished before step G can begin.',
      'Step J must be finished before step K can begin.',
      'Step K must be finished before step L can begin.',
      'Step K must be finished before step M can begin.',
      'Step K must be finished before step N can begin.',
    ]

    parsed_steps = StepParser.new(inputs).parse

    expect(Workflow.new(parsed_steps).run).to eq('ACDBEFIJGKLMN')
  end

  it 'order4' do
    inputs = [
      'Step Z must be finished before step B can begin.',
      'Step X must be finished before step B can begin.',
      'Step Y must be finished before step B can begin.',
      'Step W must be finished before step B can begin.',
      'Step B must be finished before step A can begin.',
    ]

    parsed_steps = StepParser.new(inputs).parse

    expect(Workflow.new(parsed_steps).run).to eq('WXYZBA')
  end

  it 'order4' do
    inputs = [
      'Step Z must be finished before step B can begin.',
      'Step X must be finished before step B can begin.',
      'Step F must be finished before step C can begin.',
      'Step G must be finished before step C can begin.',
    ]

    parsed_steps = StepParser.new(inputs).parse

    expect(Workflow.new(parsed_steps).run).to eq('FGCXZB')
  end

  it 'total_duration' do    inputs = [
    'Step A must be finished before step B can begin.',
    'Step B must be finished before step C can begin.',
    'Step C must be finished before step D can begin.',
    'Step D must be finished before step E can begin.'
  ]
  parsed_steps = StepParser.new(inputs).parse

  expect(Workflow.new(parsed_steps).total_duration).to eq(315)
  end
end

describe Solution do
  it 'tests' do
    Solution.run_part1_test
    Solution.run_part2_test
  end
end

puts Solution.new('./input.txt').run_part1
puts Solution.new('./input.txt').run_part2
