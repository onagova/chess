require_relative 'rook'
require_relative 'eight_way_directions'
require_relative 'castling_record'

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

    castling = king_side_castling?
    moves << castling unless castling.nil?

    castling = queen_side_castling?
    moves << castling unless castling.nil?

    moves
  end

  def move(dest)
    move = validate_destination(dest)

    @position = move.dest
    if move.is_a?(CastlingRecord)
      move.rook.apply_castling(move.rook_dest)
    elsif move.is_a?(CaptureRecord)
      move.captured.enabled = false
    end

    @board.move_history << move
    @has_moved = true
  end

  def attack_positions
    moves = []

    NON_DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir, 1)
    end

    DIAGONAL_DIRECTIONS.each do |dir|
      moves.concat directional_reachables(dir, 1)
    end

    moves.map(&:dest)
  end

  def king_side_castling_right?
    castling_right?(7)
  end

  def queen_side_castling_right?
    castling_right?(0)
  end

  def to_s
    "K#{super}"
  end

  def pretty_print
    '♚'.colorize(color_code)
  end

  private

  def castling_right?(rook_x)
    return false if @has_moved

    rook = @board.piece_at(Vector2Int.new(rook_x, @position.y))
    return false unless rook.is_a?(Rook)
    return false if rook.has_moved

    rook.owner.set == @owner.set
  end

  def king_side_castling?
    castling?(7, 1)
  end

  def queen_side_castling?
    castling?(0, -1)
  end

  def castling?(rook_x, right_mult)
    return nil if @has_moved

    rook = @board.piece_at(Vector2Int.new(rook_x, @position.y))
    return nil unless rook.is_a?(Rook)
    return nil if rook.has_moved

    king_dest = @position + Vector2Int.new(2 * right_mult, 0)
    return nil unless @board.piece_at(king_dest).nil?

    rook_dest = @position + Vector2Int.new(1 * right_mult, 0)
    return nil unless @board.piece_at(rook_dest).nil?

    enemy_set = @owner.set == WHITE ? BLACK : WHITE
    attacked_positions = @board.attack_positions(enemy_set)
    return nil if attacked_positions.include?(@position)
    return nil if attacked_positions.include?(king_dest)
    return nil if attacked_positions.include?(rook_dest)

    CastlingRecord.new(self, king_dest, rook, rook_dest)
  end

  def create_mock(move)
    mock = super
    mock[:has_moved] = @has_moved
    return mock unless move.is_a?(CastlingRecord)

    mock[:rook_src] = move.rook.position
    mock
  end

  def apply_mock(mock)
    move = mock[:move]
    @position = move.dest
    @has_moved = true
    @board.move_history << move

    if move.is_a?(CastlingRecord)
      move.rook.apply_castling(move.rook_dest)
    elsif move.is_a?(CaptureRecord)
      move.captured.enabled = false
    end
  end

  def revert_mock(mock)
    move = mock[:move]
    @position = mock[:prev_pos]
    @has_moved = mock[:has_moved]
    @board.move_history.pop

    if move.is_a?(CastlingRecord)
      move.rook.revert_castling(mock[:rook_src])
    elsif move.is_a?(CaptureRecord)
      move.captured.enabled = true
    end
  end
end
