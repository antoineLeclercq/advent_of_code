require 'pp'
require 'date'

class Object
  def first_only
    raise 'should only be one element' if size > 1
    first
  end
end

class Solution
  attr_reader :guard_actions

  def initialize(path)
    inputs = File.read(path).split("\n").compact
    @guard_actions = inputs.map { |i| GuardAction.new(i) }
  end

  def run
    temp = guards_shifts.reduce(Hash.new(0)) do |r, gs|
      r[gs] = gs.total_time_spent_sleeping
      r
    end
    winner = guards_shifts.max_by { |gs| temp[gs] }
    winner.guard_id * winner.most_frequent_minute_spent_sleeping
  end

  def shifts
    @shifts ||= guard_actions
      .group_by(&:rounded_date)
      .map { |k, v| Shift.new(date: k, actions: v) }
  end

  def guards_shifts
    @guards_shifts ||= shifts
      .group_by(&:guard_id)
      .map { |k, v| GuardShifts.new(guard_id: k, shifts: v) }
  end
end

class GuardAction
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def to_time
    @to_time ||= raw.scan(/\[.+\]/).flatten.first
  end

  def date
    @date ||= raw.scan(/\[(\d+-\d+-\d+) /).flatten.first
  end

  def hour
    @hour ||= raw.scan(/ (\d+):\d+\]/).flatten.first.to_i
  end

  def minute
    @minute ||= raw.scan(/ \d+:(\d+)\]/).flatten.first.to_i
  end

  def guard_id
    @guard_id ||= raw.scan(/#(\d+)/).flatten.first&.to_i
  end

  def action
    @action ||= raw.scan(/(#\d+ )? ([a-zA-Z]+ [a-zA-Z]+)$/).flatten.last
  end

  def rounded_date
    return @rounded_date if @rounded_date

    if hour == 23
      @rounded_date = (Date.parse(date) + 1).to_s
    else
      @rounded_date = date
    end
  end
end

class Shift
  attr_reader :date, :actions

  def initialize(date:, actions:)
    @date = date
    @actions = actions.sort_by(&:minute)
  end

  def guard_id
    @guard_id = actions.find(&:guard_id).guard_id
  end

  def sleeping_intervals
    return @sleeping_intervals if @sleeping_intervals

    res = []
    current = {}
    actions.each do |a|
      if a.action == 'falls asleep'
        current[:start] = a.minute
      elsif a.action == 'wakes up'
        current[:end] = a.minute
        res << current
        current = {}
      end
    end

    @sleeping_intervals = res
  end

  def time_spent_sleeping
    @time_spent_sleeping ||= sleeping_intervals.reduce(0) { |res, i| res += i[:end] - i[:start] }
  end

  def minutes_spent_sleeping
    @all_minutes_spent_sleeping ||= sleeping_intervals.reduce([]) { |res, i| res << (i[:start]...i[:end]).to_a; res }.flatten
  end
end

class GuardShifts
  attr_reader :guard_id, :shifts

  def initialize(guard_id:, shifts:)
    @guard_id = guard_id
    @shifts = shifts
  end

  def total_time_spent_sleeping
    shifts.reduce(0) { |r, c| r += c.time_spent_sleeping }
  end

  def most_frequent_minute_spent_sleeping
    minutes = shifts.map(&:minutes_spent_sleeping).flatten
    freq = minutes.reduce(Hash.new(0)) { |r,m| r[m] += 1; r }
    minutes.max_by { |m| freq[m] }
  end
end

result = Solution.new('./test_input.txt').run
output = (result == 240) ? 'GOOD' : "WRONG
got #{result}, expected 240"

puts output
p Solution.new('./input.txt').run
