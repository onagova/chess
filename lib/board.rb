require './lib/capture_record'

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

  def pieces_by_set(set)
    @pieces.select { |piece| piece.owner.set == set }
  end

  def king_exposed?(set)
    nil
  end

  def attack_positions(set)
    pieces_by_set(set).reduce([]) { |a, v| a.concat(v.attack_positions) }
  end
end
