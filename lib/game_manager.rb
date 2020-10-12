require_relative 'essentials'
require_relative 'vector_2_int'
require_relative 'board'
require_relative 'human_player'
require_relative 'pawn'
require_relative 'capture_record'
require_relative 'command/move_command'
require_relative 'command/draw_request_command'
require_relative 'command/threefold_repetition_command'
require_relative 'command/early_threefold_repetition_command'
require_relative 'command/fifty_move_command'
require_relative 'command/early_fifty_move_command'
require_relative 'custom_error'

class GameManager
  include Essentials

  def initialize
    @board = nil
    @white_player = nil
    @black_player = nil
    @position_summaries = nil
  end

  def new_game
    @white_player = HumanPlayer.new(WHITE)
    @black_player = HumanPlayer.new(BLACK)
    @board = Board.new(@white_player, @black_player)
    @position_summaries = { WHITE => Hash.new(0), BLACK => Hash.new(0) }
  end

  def play
    new_game

    last_command = nil
    current_player = @white_player
    update_position_summaries(current_player)
    end_report = @board.end_report

    until end_report.locked
      iteration, last_command = play_turn(current_player, last_command)

      case iteration
      when :break then break
      end

      current_player = other_player(current_player)
      update_position_summaries(current_player)
      end_report = @board.end_report
    end

    declare_winner(end_report, last_command)
  end

  def threefold_repetition?
    @position_summaries.values.any? do |summaries|
      summaries.values.any? { |count| count >= 3 }
    end
  end

  def next_threefold_repetitions(player)
    other = other_player(player)
    summaries = @position_summaries[other.set]
    repeated = summaries.each_key.select { |key| summaries[key] == 2 }
    return [] if repeated.empty?

    future_summaries = @board.future_position_summaries(player.set)
    future_summaries.select { |item| repeated.include?(item[1]) }
  end

  def fifty_move?
    return false unless @board.move_history.size >= 50

    @board.move_history[-50, 50].none? do |move|
      move.is_a?(CaptureRecord) || move.piece.is_a?(Pawn)
    end
  end

  def next_fifty_moves(player)
    return [] unless @board.move_history.size >= 49

    available = @board.move_history[-49, 49].none? do |move|
      move.is_a?(CaptureRecord) || move.piece.is_a?(Pawn)
    end
    return [] unless available

    @board.legal_moves(player.set).reject do |move|
      move.is_a?(CaptureRecord) || move.piece.is_a?(Pawn)
    end
  end

  private

  def play_turn(player, last_command)
    system 'clear'
    puts @board.pretty_print + "\n"

    case last_command
    when EarlyThreefoldRepetitionCommand
      src_fr = last_command.src.to_file_rank
      dest_fr = last_command.dest.to_file_rank
      puts "Early threefold repetition #{src_fr} -> #{dest_fr} was not available"
      puts ''
    when EarlyFiftyMoveCommand
      src_fr = last_command.src.to_file_rank
      dest_fr = last_command.dest.to_file_rank
      puts "Early fifty-move #{src_fr} -> #{dest_fr} was not available"
      puts ''
    end

    player.hint_threefold(self)
    player.hint_fifty_move(self)
    puts "[#{player.set.capitalize}'s turn]"

    if last_command.is_a?(DrawRequestCommand)
      return [:break, last_command] if player.accept_draw
    end

    begin
      command = player.next_command(@board)
      iteration = handle_command(command, player)
    rescue CustomError => e
      puts e
      puts 'Try again...'
      puts ''
      retry
    end

    [iteration, command]
  end

  def handle_command(command, owner)
    case command
    when EarlyThreefoldRepetitionCommand
      src = command.src
      dest = command.dest

      available = next_threefold_repetitions(owner).any? do |item|
        item[0].piece.position == src && item[0].dest == dest
      end

      @board.move_piece(src, dest, owner.set)
      available ? :break : :normal
    when ThreefoldRepetitionCommand
      raise CustomError, 'threefold repetition draw is not available' unless threefold_repetition?

      :break
    when EarlyFiftyMoveCommand
      src = command.src
      dest = command.dest

      available = next_fifty_moves(owner).any? do |move|
        move.piece.position == src && move.dest == dest
      end

      @board.move_piece(src, dest, owner.set)
      available ? :break : :normal
    when FiftyMoveCommand
      raise CustomError, 'fifty-move rule draw is not available' unless fifty_move?

      :break
    when MoveCommand
      @board.move_piece(command.src, command.dest, owner.set)
      :normal
    else
      raise CustomError, 'invalid command'
    end
  end

  def declare_winner(end_report, last_command)
    system 'clear'
    puts @board.pretty_print + "\n"

    if last_command.is_a?(DrawRequestCommand)
      puts 'Game Over! Draw by agreement'
    elsif last_command.is_a?(ThreefoldRepetitionCommand) ||
          last_command.is_a?(EarlyThreefoldRepetitionCommand)
      puts 'Game Over! Draw by threefold repetition'
    elsif last_command.is_a?(FiftyMoveCommand) ||
          last_command.is_a?(EarlyFiftyMoveCommand)
      puts 'Game Over! Draw by fifty-move rule'
    elsif end_report.winner.nil?
      puts 'Game Over! Stalemate'
    else
      puts "CHECKMATE! #{end_report.winner.capitalize} wins"
    end
  end

  def update_position_summaries(player)
    summary = @board.position_summary
    @position_summaries[player.set][summary] += 1
  end

  def other_player(player)
    player == @white_player ? @black_player : @white_player
  end
end
