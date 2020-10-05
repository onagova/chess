require './lib/piece'

class Knight < Piece
  OFFSET = [
    Vector2Int.new(-2, -1),
    Vector2Int.new(-2, 1),
    Vector2Int.new(-1, -2),
    Vector2Int.new(-1, 2),
    Vector2Int.new(1, -2),
    Vector2Int.new(1, 2),
    Vector2Int.new(2, -1),
    Vector2Int.new(2, 1)
  ].freeze

  def reachables
    OFFSET.map { |v| reachable?(@position + v) }.reject(&:nil?)
  end

  def pretty_print
    '♞'.colorize(color_code)
  end

  private

  def reachable?(dest)
    return nil if @board.out_of_bounds?(dest)

    piece = @board.piece_at(dest)
    if piece.nil?
      MoveRecord.new(self, dest)
    elsif piece.owner.set != @owner.set
      CaptureRecord.new(self, dest, piece)
    end
  end
end
