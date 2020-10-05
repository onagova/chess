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
end
