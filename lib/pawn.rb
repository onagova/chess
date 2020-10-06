require_relative 'piece'
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

    capture_dests.each do |dest|
      capture = capturable?(dest) || en_passant_able?(dest)
      moves << capture unless capture.nil?
    end

    moves
  end

  def move(dest)
    super
    @has_moved = true
  end

  def attack_positions
    capture_dests.reject { |dest| @board.out_of_bounds?(dest) }
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

  def capturable?(dest)
    return nil if @board.out_of_bounds?(dest)
    return nil unless capture_dests.include?(dest)

    enemy = @board.piece_at(dest)
    return nil if enemy.nil?
    return nil if enemy.owner.set == @owner.set

    CaptureRecord.new(self, dest, enemy)
  end

  def en_passant_able?(dest)
    return nil if @board.out_of_bounds?(dest)
    return nil unless capture_dests.include?(dest)
    return nil unless @board.piece_at(dest).nil?

    record = @board.last_move
    return nil unless record.is_a?(EnPassantTriggerRecord)
    return nil unless record.en_passant_pos == dest

    enemy = record.piece
    return nil if enemy.owner.set == @owner.set

    CaptureRecord.new(self, dest, enemy)
  end

  def capture_dests
    [
      position + Vector2Int.new(-1, @forward),
      position + Vector2Int.new(1, @forward)
    ]
  end
end
