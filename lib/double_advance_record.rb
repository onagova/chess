require './lib/move_record'
require './lib/vector_2_int'

class DoubleAdvanceRecord < MoveRecord
  attr_reader :en_passant_pos

  def initialize(pawn, dest)
    super
    @en_passant_pos = Vector2Int.new(dest.x, dest.y - pawn.forward)
  end
end
