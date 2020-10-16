require_relative 'player'
require_relative '../commands/fifty_move_command'
require_relative '../commands/move_command'
require_relative '../commands/threefold_repetition_command'
require_relative '../pieces/rook'

Dir['.lib/commands/*'].sort.each { |file| require file }

class CPUPlayer < Player
  def initialize(set)
    super(set, 'CPU')
  end

  def next_command(game_manager)
    return ThreefoldRepetitionCommand.new if game_manager.threefold_repetition?
    return FiftyMoveCommand.new if game_manager.fifty_move?

    rand_move = game_manager.board.legal_moves(@set).sample
    MoveCommand.new(rand_move.src, rand_move.dest)
  end

  def accept_draw
    true
  end

  def hint_threefold(_); end

  def hint_fifty_move(_); end

  def promote(_)
    return @promotion_backlog.shift unless @promotion_backlog.empty?

    Queen
  end
end
