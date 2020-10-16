require_relative '../move_records/promotion_move_record'
require_relative '../move_records/promotion_capture_record'

class Player
  MAX_NAME_LENGTH = 6

  attr_reader :name, :set

  def initialize(set, name = 'Anon')
    @name = name
    @set = set
    @promotion_backlog = []
  end

  def next_command(_); end

  def accept_draw; end

  def hint_threefold(_); end

  def hint_fifty_move(_); end

  def promote(_); end

  def assign_promotion_backlog(moves)
    promotion_moves = moves.select do |move|
      move.is_a?(PromotionMoveRecord) || move.is_a?(PromotionCaptureRecord)
    end
    @promotion_backlog = promotion_moves.map(&:promotion)
  end
end
