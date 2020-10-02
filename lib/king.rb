require './lib/piece'
require './lib/eight_way_directions'

class King < Piece
  include EightWayDirections

  def initialize(board, position, owner)
    super
    @has_moved = false
  end

  def reachables
    moves = []

    NON_DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir, 1)
    end

    DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir, 1)
    end

    moves
  end

  def move(dest)
    super
    @has_moved = true
  end
end