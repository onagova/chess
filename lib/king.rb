require './lib/piece'
require './lib/eight_way_directions'
require './lib/rook'
require './lib/castling_record'

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

  def legal_moves
    moves = reachables

    moves.select do |move|
      temp = @position
      @position = move.dest

      if move.is_a?(CastlingRecord)
        rook_src = move.rook.position
        move.rook.force_move(move.rook_dest)

        safe = !@board.king_exposed?(@owner.set)

        move.rook.force_move(rook_src)
      else
        captured = move.is_a?(CaptureRecord) ? move.captured : nil
        captured&.enabled = false

        safe = !@board.king_exposed?(@owner.set)

        captured&.enabled = true
      end

      @position = temp
      safe
    end
  end

  def move(dest)
    move = validate_destination(dest)

    @position = move.dest
    if move.is_a?(CastlingRecord)
      move.rook.force_move(move.rook_dest)
    elsif move.is_a?(CaptureRecord)
      move.captured.enabled = false
    end

    @board.last_move = move
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

  private

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
end
