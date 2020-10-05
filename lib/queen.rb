require './lib/piece'
require './lib/eight_way_directions'

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
end
