require_relative 'piece'
require_relative 'eight_way_directions'

class Rook < Piece
  include EightWayDirections

  attr_reader :has_moved

  def initialize(board, position, owner, has_moved = false)
    super(board, position, owner)
    @has_moved = has_moved
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

  def apply_castling(pos)
    @position = pos
    @has_moved = true
  end

  def revert_castling(pos)
    @position = pos
    @has_moved = false
  end

  def to_s
    "R#{super}"
  end

  def pretty_print
    '♜'.colorize(color_code)
  end

  private

  def create_mock(move)
    mock = super
    mock[:has_moved] = @has_moved
    mock
  end

  def apply_mock(mock)
    super
    @has_moved = true
  end

  def revert_mock(mock)
    super
    @has_moved = mock[:has_moved]
  end
end
