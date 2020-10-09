require_relative 'rook'
require_relative 'en_passant_trigger_record'

class Pawn < Piece
  attr_reader :forward

  def initialize(board, position, owner)
    super
    @has_moved = false
    @forward = owner.set == WHITE ? 1 : -1
  end

  def reachables
    moves = []

    move = advanceable?
    moves << move unless move.nil?

    move = double_advanceable?
    moves << move unless move.nil?

    moves.concat capturables?
    moves.concat en_passant_ables?

    moves
  end

  def move(dest)
    super
    @has_moved = true

    advanced_pos = @position + Vector2Int.new(0, forward)
    promote if @board.out_of_bounds?(advanced_pos)
  end

  def attack_positions
    capture_dests.reject { |dest| @board.out_of_bounds?(dest) }
  end

  def en_passant_ables?
    captures = []

    capture_dests.each do |dest|
      next if @board.out_of_bounds?(dest)

      # next unless capture_dests.include?(dest)

      next unless @board.piece_at(dest).nil?

      record = @board.last_move
      next unless record.is_a?(EnPassantTriggerRecord)
      next unless record.en_passant_pos == dest

      enemy = record.piece
      next if enemy.owner.set == @owner.set

      captures << CaptureRecord.new(self, dest, enemy)
    end

    captures
  end

  def pretty_print
    '♟︎'.colorize(color_code)
  end

  private

  def advanceable?
    dest = position + Vector2Int.new(0, @forward)
    return nil if @board.out_of_bounds?(dest)
    return nil unless @board.piece_at(dest).nil?

    MoveRecord.new(self, dest)
  end

  def double_advanceable?
    return nil if @has_moved

    dest = position + Vector2Int.new(0, @forward * 2)
    return nil if @board.out_of_bounds?(dest)
    return nil unless @board.piece_at(dest).nil?

    inbetween = position + Vector2Int.new(0, @forward)
    return nil unless @board.piece_at(inbetween).nil?

    left_piece = @board.piece_at(dest + Vector2Int.new(-1, 0))
    right_piece = @board.piece_at(dest + Vector2Int.new(1, 0))

    en_passant_trigger =
      (left_piece.is_a?(Pawn) && left_piece.owner.set != @owner.set) ||
      (right_piece.is_a?(Pawn) && right_piece.owner.set != @owner.set)

    if en_passant_trigger
      EnPassantTriggerRecord.new(self, dest)
    else
      MoveRecord.new(self, dest)
    end
  end

  def capturables?
    captures = []

    capture_dests.each do |dest|
      next if @board.out_of_bounds?(dest)

      # next unless capture_dests.include?(dest)

      enemy = @board.piece_at(dest)
      next if enemy.nil?
      next if enemy.owner.set == @owner.set

      captures << CaptureRecord.new(self, dest, enemy)
    end

    captures
  end

  def capture_dests
    [
      position + Vector2Int.new(-1, @forward),
      position + Vector2Int.new(1, @forward)
    ]
  end

  def promote
    promotion = owner.promote(self)
    promoted =
      if promotion == Rook
        Rook.new(@board, @position, @owner, true)
      else
        promotion.new(@board, @position, @owner)
      end

    @board.pieces.delete(self)
    @board.pieces << promoted
  end
end
