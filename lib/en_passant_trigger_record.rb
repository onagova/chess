require_relative 'move_record'
require_relative 'vector_2_int'

class EnPassantTriggerRecord < MoveRecord
  attr_reader :en_passant_pos

  def initialize(pawn, dest)
    super
    @en_passant_pos = Vector2Int.new(dest.x, dest.y - pawn.forward)
  end
end
