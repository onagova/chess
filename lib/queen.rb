require_relative 'piece'
require_relative 'eight_way_directions'

class Queen < Piece
  include EightWayDirections

  def reachables
    moves = []

    NON_DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir)
    end

    DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir)
    end

    moves
  end

  def to_s
    "Q#{super}"
  end

  def pretty_print
    '♛'.colorize(color_code)
  end
end
