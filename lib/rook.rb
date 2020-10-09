require_relative 'piece'
require_relative 'eight_way_directions'

class Rook < Piece
  include EightWayDirections

  attr_reader :has_moved

  def initialize(board, position, owner)
    super
    @has_moved = false
  end

  def reachables
    moves = []

    NON_DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir)
    end

    moves
  end

  def move(dest)
    super
    @has_moved = true
  end

  def force_move(dest)
    @position = dest
    @has_moved = true
  end

  def to_s
    "R#{super}"
  end

  def pretty_print
    '♜'.colorize(color_code)
  end
end
