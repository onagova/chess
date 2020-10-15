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

  def future_position_summaries
    results = []

    reachables.each do |move|
      mock = create_mock(move)
      apply_mock(mock)
      safe = !@board.king_exposed?(@owner.set)
      summary = @board.position_summary
      revert_mock(mock)
      results << [move, summary] if safe
    end

    results
  end

  def move(dest)
    move = validate_destination(dest)
    captured = @board.piece_at(move.capture_pos) if move.is_a?(CaptureRecord)

    @position = move.dest
    captured&.enabled = false

    @board.move_history << move
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
        moves << MoveRecord.new(
          self.class,
          @position,
          current_dest
        )
      elsif piece.owner.set != @owner.set
        moves << CaptureRecord.new(
          self.class,
          @position,
          current_dest,
          piece.position
        )
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
    captured = @board.piece_at(move.capture_pos) if move.is_a?(CaptureRecord)

    { move: move, captured: captured }
  end

  def apply_mock(mock)
    @position = mock[:move].dest
    mock[:captured]&.enabled = false
    @board.move_history << mock[:move]
  end

  def revert_mock(mock)
    @position = mock[:move].src
    mock[:captured]&.enabled = true
    @board.move_history.pop
  end

  def color_code
    @owner.set == WHITE ? WHITE_COLOR_CODE : BLACK_COLOR_CODE
  end
end
