require './lib/piece'
require './lib/eight_way_directions'

class Bishop < Piece
  include EightWayDirections

  def reachables
    moves = []

    DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir)
    end

    moves
  end

  def pretty_print
    '♝'.colorize(color_code)
  end
end
