require_relative 'move_record'
require_relative 'pawn'

class PromotionMoveRecord < MoveRecord
  attr_reader :promotion

  def initialize(src, dest, promotion)
    super(Pawn, src, dest)
    @promotion = promotion
  end
end
