require_relative 'essentials'
require_relative 'vector_2_int'
require_relative 'capture_record'
require_relative 'string'
require_relative 'custom_error'

class Piece
  include Essentials

  attr_accessor :enabled
  attr_reader :position, :owner

  def initialize(board, position, owner)
    @enabled = true
    @board = board
    @position = position
    @owner = owner
  end

  def reachables
    []
  end

  def legal_moves
    reachables.select do |move|
      mock = create_mock(move)
      apply_mock(mock)
      safe = !@board.king_exposed?(@owner.set)
      revert_mock(mock)
      safe
    end
  end


    end
  end

  def move(dest)
    move = validate_destination(dest)

    @position = move.dest
    move.captured.enabled = false if move.is_a?(CaptureRecord)

    @board.last_move = move
  end

  def attack_positions
    reachables.map(&:dest)
  end

  def to_s
    @position.to_file_rank
  end

  def pretty_print
    '♦'.colorize(color_code)
  end

  private

  def directional_reachables(dir, limit = -1)
    moves = []

    current_dest = @position + dir
    until moves.size == limit
      break if @board.out_of_bounds?(current_dest)

      piece = @board.piece_at(current_dest)

      if piece.nil?
        moves << MoveRecord.new(self, current_dest)
      elsif piece.owner.set != @owner.set
        moves << CaptureRecord.new(self, current_dest, piece)
        break
      else
        break
      end

      current_dest += dir
    end

    moves
  end

  def validate_destination(dest)
    move = legal_moves.find { |v| v.dest == dest }

    msg = "illegal move #{@position.to_file_rank} -> #{dest.to_file_rank}"
    raise CustomError, msg if move.nil?

    move
  end

  def create_mock(move)
    {
      move: move,
      prev_pos: @position,
      prev_move: @board.last_move
    }
  end

  def apply_mock(mock)
    move = mock[:move]
    captured = move.is_a?(CaptureRecord) ? move.captured : nil

    @position = move.dest
    captured&.enabled = false
    @board.last_move = move
  end

  def revert_mock(mock)
    move = mock[:move]
    captured = move.is_a?(CaptureRecord) ? move.captured : nil

    @position = mock[:prev_pos]
    captured&.enabled = true
    @board.last_move = mock[:prev_move]
  end

  def color_code
    @owner.set == WHITE ? WHITE_COLOR_CODE : BLACK_COLOR_CODE
  end
end
