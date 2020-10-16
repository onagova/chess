require_relative 'move_record'
require_relative '../vector_2_int'
require_relative '../pieces/pawn'

class EnPassantTriggerRecord < MoveRecord
  attr_reader :en_passant_pos

  def initialize(src, dest)
    super(Pawn, src, dest)
    forward = src.y < dest.y ? 1 : -1
    @en_passant_pos = Vector2Int.new(dest.x, dest.y - forward)
  end
end
