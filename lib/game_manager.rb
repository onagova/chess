require_relative 'essentials'
require_relative 'vector_2_int'
require_relative 'board'
require_relative 'human_player'
require_relative 'command/move_command'
require_relative 'command/draw_request_command'
require_relative 'custom_error'

class GameManager
  include Essentials

  def initialize
    @board = nil
    @white_player = nil
    @black_player = nil
  end

  def new_game
    @white_player = HumanPlayer.new(WHITE)
    @black_player = HumanPlayer.new(BLACK)
    @board = Board.new(@white_player, @black_player)
  end

  def play
    new_game
    current_player = @white_player
    last_command = nil

    until @board.locked
      system 'clear'
      puts @board.pretty_print + "\n"
      puts "[#{current_player.set.capitalize}'s turn]"

      if last_command.is_a?(DrawRequestCommand)
        break if current_player.accept_draw
      end

      begin
        last_command = current_player.next_command(@board)
        handle_command(last_command, current_player)
      rescue CustomError => e
        puts e
        puts 'try again...'
        puts ''
        retry
      end

      current_player = other_player(current_player)
    end

    declare_winner(last_command)
  end

  private

  def handle_command(command, owner)
    if command.is_a?(MoveCommand)
      @board.move_piece(command.src, command.dest, owner.set)
    else
      raise CustomError, 'invalid command'
    end
  end

  def declare_winner(last_command)
    system 'clear'
    puts @board.pretty_print + "\n"

    if last_command.is_a?(DrawRequestCommand)
      puts 'Game Over! Draw by agreement'
    elsif @board.winner.nil?
      puts 'Game Over! Stalemate'
    else
      puts "CHECKMATE! #{@board.winner.capitalize} wins"
    end
  end

  def other_player(player)
    player == @white_player ? @black_player : @white_player
  end
end
