require_relative 'capture_record'
require_relative 'pawn'

class PromotionCaptureRecord < CaptureRecord
  attr_reader :promotion

  def initialize(src, dest, capture_pos, promotion)
    super(Pawn, src, dest, capture_pos)
    @promotion = promotion
  end
end
