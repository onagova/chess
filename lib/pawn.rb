require './lib/piece'
require './lib/double_advance_record'

class Pawn < Piece
  attr_reader :forward

  def initialize(board, position, owner)
    super
    @has_moved = false
    @forward = owner.set == WHITE ? 1 : -1
  end

  def reachables
    moves = []

    dest = @position + Vector2Int.new(0, @forward)
    moves << MoveRecord.new(self, dest) if advanceable?(dest)

    dest = @position + Vector2Int.new(0, @forward * 2)
    moves << DoubleAdvanceRecord.new(self, dest) if double_advanceable?(dest)

    dest = @position + Vector2Int.new(-1, @forward)
    captured = capturable?(dest) || en_passant_able?(dest)
    moves << CaptureRecord.new(self, dest, captured) unless captured.nil?

    dest = @position + Vector2Int.new(1, @forward)
    captured = capturable?(dest) || en_passant_able?(dest)
    moves << CaptureRecord.new(self, dest, captured) unless captured.nil?

    moves
  end

  def move(dest)
    super
    @has_moved = true
  end

  private

  def advanceable?(dest)
    return false if @board.out_of_bounds?(dest)

    one_step = position + Vector2Int.new(0, @forward)
    return false unless one_step == dest
    return false unless @board.piece_at(dest).nil?

    true
  end

  def double_advanceable?(dest)
    return false if @has_moved
    return false if @board.out_of_bounds?(dest)

    two_step = position + Vector2Int.new(0, @forward * 2)
    return false unless two_step == dest
    return false unless @board.piece_at(dest).nil?

    inbetween = position + Vector2Int.new(0, @forward)
    return false unless @board.piece_at(inbetween).nil?

    true
  end

  def capturable?(dest)
    return nil if @board.out_of_bounds?(dest)
    return nil unless capture_dests.include?(dest)

    enemy = @board.piece_at(dest)
    return nil if enemy.nil?
    return nil if enemy.owner.set == @owner.set

    enemy
  end

  def en_passant_able?(dest)
    return nil if @board.out_of_bounds?(dest)
    return nil unless capture_dests.include?(dest)
    return nil unless @board.piece_at(dest).nil?

    record = @board.last_move
    return nil unless record.is_a?(DoubleAdvanceRecord)
    return nil unless record.en_passant_pos == dest

    enemy = record.piece
    return nil if enemy.owner.set == @owner.set

    enemy
  end

  def capture_dests
    [
      position + Vector2Int.new(-1, @forward),
      position + Vector2Int.new(1, @forward)
    ]
  end
end
