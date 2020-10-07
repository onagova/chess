require_relative 'file_rank_converter'

class Vector2Int
  include FileRankConverter

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    Vector2Int.new(@x + other.x, @y + other.y)
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def to_file_rank
    "#{('a'.ord + x).chr}#{y + 1}"
  end

  def self.from_file_rank(fr)
    x = fr[0].ord - 'a'.ord
    y = fr[1].to_i - 1
    Vector2Int.new(x, y)
  end
end
