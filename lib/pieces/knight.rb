require_relative 'piece'

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

  def to_s
    "N#{super}"
  end

  def pretty_print
    '♞'.colorize(color_code)
  end

  private

  def reachable?(dest)
    return nil if @board.out_of_bounds?(dest)

    piece = @board.piece_at(dest)
    if piece.nil?
      MoveRecord.new(Knight, @position, dest)
    elsif piece.owner.set != @owner.set
      CaptureRecord.new(Knight, @position, dest, piece.position)
    end
  end
end
