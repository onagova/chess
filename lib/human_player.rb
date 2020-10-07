require_relative 'player'
require_relative 'command/move_command'
require_relative 'command/draw_request_command'

class HumanPlayer < Player
  def next_command(_)
    print 'Enter a command: '
    input = gets.chomp.downcase

    mdata = input.match(/^([a-z][0-9]) ([a-z][0-9])$/)
    unless mdata.nil?
      src = Vector2Int.from_file_rank(mdata[1])
      dest = Vector2Int.from_file_rank(mdata[2])
      return MoveCommand.new(src, dest)
    end

    mdata = input.match(/^draw ([a-z][0-9]) ([a-z][0-9])$/)
    unless mdata.nil?
      src = Vector2Int.from_file_rank(mdata[1])
      dest = Vector2Int.from_file_rank(mdata[2])
      return DrawRequestCommand.new(src, dest)
    end

    nil
  end

  def accept_draw
    print 'Accept draw? [Y/n] '
    gets.chomp.downcase == 'y'
  end
end
