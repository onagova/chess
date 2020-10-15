require_relative 'move_record'

class CastlingRecord < MoveRecord
  attr_reader :rook_src, :rook_dest

  def initialize(king_src, king_dest, rook_src, rook_dest)
    super(King, king_src, king_dest)
    @rook_src = rook_src
    @rook_dest = rook_dest
  end
end
