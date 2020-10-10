require_relative 'player'
require_relative 'queen'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'
require_relative 'command/draw_request_command'
require_relative 'command/threefold_repetition_command'
require_relative 'command/early_threefold_repetition_command'

class HumanPlayer < Player
  HINT_THREEFOLD_STRING = 'Hint: Draw by threefold repetition is available.'.freeze

  def next_command(_)
    print 'Enter a command: '
    input = gets.chomp.downcase

    return ThreefoldRepetitionCommand.new if input == 'threefold'

    mdata = input.match(/^([a-z][0-9]) ([a-z][0-9])$/)
    return move_command(MoveCommand, mdata[1], mdata[2]) unless mdata.nil?

    mdata = input.match(/^draw ([a-z][0-9]) ([a-z][0-9])$/)
    return move_command(DrawRequestCommand, mdata[1], mdata[2]) unless mdata.nil?

    mdata = input.match(/^threefold ([a-z][0-9]) ([a-z][0-9])$/)
    return move_command(EarlyThreefoldRepetitionCommand, mdata[1], mdata[2]) unless mdata.nil?

    nil
  end

  def accept_draw
    print 'Accept draw? [Y/n] '
    gets.chomp.downcase == 'y'
  end

  def hint_threefold(game_manager)
    if game_manager.threefold_repetition?
      puts HINT_THREEFOLD_STRING
      puts "Enter 'threefold' command to draw the game."
      puts ''
      return
    end

    next_repeated = game_manager.next_threefold_repetitions(self)
    return if next_repeated.empty?

    move = next_repeated[0][0]
    src = move.piece.position.to_file_rank
    dest = move.dest.to_file_rank
    puts HINT_THREEFOLD_STRING
    puts "Enter 'threefold #{src} #{dest}' command to draw the game."
    puts ''
  end

  def promote(pawn)
    puts "\n1)Queen 2)Rook 3)Bishop 4)Knight"
    print "Select a promotion for #{pawn}: "
    input = gets.chomp

    unless input.match?(/^[1-4]$/)
      puts 'Invalid input. try again...'
      return promote(pawn)
    end

    [Queen, Rook, Bishop, Knight][input.to_i - 1]
  end

  private

  def move_command(klass, src_fr, dest_fr)
    src = Vector2Int.from_file_rank(src_fr)
    dest = Vector2Int.from_file_rank(dest_fr)
    klass.new(src, dest)
  end
end
