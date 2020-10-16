require_relative 'board'
require_relative 'custom_error'
require_relative 'essentials'
require_relative 'save_manager'
require_relative './move_records/capture_record'
require_relative './pieces/pawn'
require_relative './players/human_player'

Dir['./lib/commands/*'].sort.each { |file| require file }

class GameManager
  include Essentials

  def initialize
    @white_player = nil
    @black_player = nil
    @board = nil
    @position_summaries = nil
    @save_manager = SaveManager.new
    @save_load_msg = ''
  end

  def play
    current_player = late_initialize

    last_command = nil
    end_report = @board.end_report

    until end_report.locked
      iteration, last_command = play_turn(current_player, last_command)

      case iteration
      when :next then next
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
      move.is_a?(CaptureRecord) || move.piece_type == Pawn
    end
  end

  def next_fifty_moves(player)
    return [] unless @board.move_history.size >= 49

    available = @board.move_history[-49, 49].none? do |move|
      move.is_a?(CaptureRecord) || move.piece_type == Pawn
    end
    return [] unless available

    @board.legal_moves(player.set).reject do |move|
      move.is_a?(CaptureRecord) || move.piece_type == Pawn
    end
  end

  private

  def late_initialize
    @position_summaries = { WHITE => Hash.new(0), BLACK => Hash.new(0) }

    puts 'Load saved game? [Y/n]: '
    input = gets.chomp.downcase
    return new_game unless input == 'y'

    puts ''
    @save_load_msg, loaded_data = @save_manager.open_load_menu
    return new_game if loaded_data.nil?

    load_game(loaded_data)
  end

  def new_game
    @white_player = HumanPlayer.new(WHITE)
    @black_player = HumanPlayer.new(BLACK)
    @board = Board.new(@white_player, @black_player)
    update_position_summaries(@white_player)

    @save_load_msg = 'starting a new game...'
    @white_player
  end

  def load_game(data)
    @white_player = data[1]
    @black_player = data[2]
    @board = Board.new(@white_player, @black_player)

    move_history = data[3]
    white_moves = move_history.values_at(
      *move_history.each_index.select(&:even?)
    )
    black_moves = move_history.values_at(
      *move_history.each_index.select(&:odd?)
    )

    @white_player.assign_promotion_backlog(white_moves)
    @black_player.assign_promotion_backlog(black_moves)

    current_player = @white_player
    update_position_summaries(current_player)

    move_history.each do |move|
      @board.move_piece(move.src, move.dest, current_player.set)

      current_player = other_player(current_player)
      update_position_summaries(current_player)
    end

    current_player
  end

  def play_turn(player, last_command)
    system 'clear'
    puts @board.pretty_print + "\n"

    unless @save_load_msg.empty?
      puts @save_load_msg
      puts ''
      @save_load_msg = ''
    end

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
        item[0].src == src && item[0].dest == dest
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
        move.src == src && move.dest == dest
      end

      @board.move_piece(src, dest, owner.set)
      available ? :break : :normal
    when FiftyMoveCommand
      raise CustomError, 'fifty-move rule draw is not available' unless fifty_move?

      :break
    when MoveCommand
      @board.move_piece(command.src, command.dest, owner.set)
      :normal
    when SaveCommand
      puts ''
      @save_load_msg = @save_manager.open_save_menu(
        "#{@white_player.name} vs #{@black_player.name}",
        @white_player,
        @black_player,
        @board.move_history
      )
      :next
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
