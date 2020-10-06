require_relative 'board'

class TestingBoard < Board
  attr_accessor :pieces

  def initialize(col_count, row_count)
    @col_count = col_count
    @row_count = row_count
  end

  def out_of_bounds?(pos)
    pos.x.negative? || pos.y.negative? ||
      pos.x >= @col_count || pos.y >= @row_count
  end
end
