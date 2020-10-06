require_relative 'move_record'

class CastlingRecord < MoveRecord
  attr_reader :rook, :rook_dest

  def initialize(king, king_dest, rook, rook_dest)
    super(king, king_dest)
    @rook = rook
    @rook_dest = rook_dest
  end
end
