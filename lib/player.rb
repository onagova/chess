class Player
  attr_reader :set

  def initialize(set)
    @set = set
    @promotion_backlog = []
  end

  def next_command(_); end

  def accept_draw; end

  def promote(_); end

  def assign_promotion_backlog(moves)
    promotion_moves = moves.select do |move|
      move.is_a?(PromotionMoveRecord) || move.is_a?(PromotionCaptureRecord)
    end
    @promotion_backlog = promotion_moves.map(&:promotion)
  end
end
