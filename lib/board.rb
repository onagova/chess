class Board
  attr_accessor :last_move

  def initialize
    @pieces = nil
    @last_move = nil
  end

  def out_of_bounds?(pos)
    pos.x.negative? || pos.y.negative? || pos.x >= 8 || pos.y >= 8
  end

  def piece_at(pos)
    @pieces.find do |piece|
      piece.enabled && piece.position == pos
    end
  end

  def king_exposed?(set)
    nil
  end
end
