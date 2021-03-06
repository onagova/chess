require_relative 'custom_error'
require_relative 'end_report'
require_relative 'essentials'
require_relative 'position_summary'
require_relative 'string'
require_relative 'vector_2_int'
require_relative './pieces/bishop'
require_relative './pieces/king'
require_relative './pieces/knight'
require_relative './pieces/pawn'
require_relative './pieces/queen'
require_relative './pieces/rook'

class Board
  include Essentials

  attr_reader :pieces, :move_history

  def initialize(white_player, black_player)
    @col_count = 8
    @row_count = 8
    @move_history = []

    @pieces = [
      Rook.new(self, Vector2Int.new(0, 0), white_player),
      Knight.new(self, Vector2Int.new(1, 0), white_player),
      Bishop.new(self, Vector2Int.new(2, 0), white_player),
      Queen.new(self, Vector2Int.new(3, 0), white_player),
      King.new(self, Vector2Int.new(4, 0), white_player),
      Bishop.new(self, Vector2Int.new(5, 0), white_player),
      Knight.new(self, Vector2Int.new(6, 0), white_player),
      Rook.new(self, Vector2Int.new(7, 0), white_player),

      Rook.new(self, Vector2Int.new(0, 7), black_player),
      Knight.new(self, Vector2Int.new(1, 7), black_player),
      Bishop.new(self, Vector2Int.new(2, 7), black_player),
      Queen.new(self, Vector2Int.new(3, 7), black_player),
      King.new(self, Vector2Int.new(4, 7), black_player),
      Bishop.new(self, Vector2Int.new(5, 7), black_player),
      Knight.new(self, Vector2Int.new(6, 7), black_player),
      Rook.new(self, Vector2Int.new(7, 7), black_player)
    ]
    0.upto(7) do |i|
      @pieces << Pawn.new(self, Vector2Int.new(i, 1), white_player)
      @pieces << Pawn.new(self, Vector2Int.new(i, 6), black_player)
    end
  end

  def out_of_bounds?(pos)
    pos.x.negative? || pos.y.negative? ||
      pos.x >= @col_count || pos.y >= @row_count
  end

  def piece_at(pos)
    @pieces.find do |piece|
      piece.enabled && piece.position == pos
    end
  end

  def pieces_by_set(set)
    @pieces.select do |piece|
      piece.enabled && piece.owner.set == set
    end
  end

  def king_exposed?(set)
    other_set = set == WHITE ? BLACK : WHITE
    captures = reachables(other_set).select do |move|
      move.is_a?(CaptureRecord)
    end
    captures.find { |move| piece_at(move.capture_pos).is_a?(King) }
  end

  def attack_positions(set)
    pieces_by_set(set).reduce([]) { |a, v| a.concat(v.attack_positions) }
  end

  def legal_moves(set)
    pieces_by_set(set).reduce([]) { |a, v| a.concat(v.legal_moves) }
  end

  def move_piece(src, dest, set)
    piece = piece_at(src)
    raise CustomError, "#{src.to_file_rank} is empty" if piece.nil?
    raise CustomError, "#{piece} is not a #{set} piece" unless piece.owner.set == set

    piece.move(dest)
  end

  def end_report
    [WHITE, BLACK].each do |set|
      next unless legal_moves(set).empty?
      return EndReport.new(true, nil) unless king_exposed?(set)

      return EndReport.new(true, set == WHITE ? BLACK : WHITE)
    end

    EndReport.new(false, nil)
  end

  def position_summary
    PositionSummary.new(self)
  end

  def future_position_summaries(set)
    pieces_by_set(set).reduce([]) do |a, v|
      a.concat v.future_position_summaries
    end
  end

  def pretty_print
    str = pretty_print_files_header
    (@row_count - 1).downto(0) { |n| str += pretty_print_rank(n) }
    str + pretty_print_files_header + pretty_print_check_all
  end

  private

  def reachables(set)
    pieces_by_set(set).reduce([]) { |a, v| a.concat(v.reachables) }
  end

  def pretty_print_files_header
    str = '   '
    0.upto(@col_count - 1) do |n|
      str += "   #{('a'.ord + n).chr}   "
    end
    str + "\n"
  end

  def pretty_print_rank(rank)
    bg_colors = rank.even? ? [44, 46] : [46, 44]
    pretty_print_rank_padding(bg_colors) +
      pretty_print_rank_content(bg_colors, rank) +
      pretty_print_rank_padding(bg_colors)
  end

  def pretty_print_rank_padding(bg_colors)
    str = '   '
    bg_index = -1
    @col_count.times do
      bg_index = (bg_index + 1) % 2
      7.times { str += ' '.colorize_bg(bg_colors[bg_index]) }
    end
    str + "\n"
  end

  def pretty_print_rank_content(bg_colors, rank)
    str = " #{rank + 1} "
    bg_index = -1
    @col_count.times do |i|
      bg_index = (bg_index + 1) % 2
      3.times { str += ' '.colorize_bg(bg_colors[bg_index]) }

      piece = piece_at(Vector2Int.new(i, rank))
      str +=
        if piece.nil? || !piece.enabled
          ' '.colorize_bg(bg_colors[bg_index])
        else
          piece.pretty_print.colorize_bg(bg_colors[bg_index])
        end

      3.times { str += ' '.colorize_bg(bg_colors[bg_index]) }
    end
    str + " #{rank + 1} \n"
  end

  def pretty_print_check_all
    str = pretty_print_check(WHITE)
    return str unless str.empty?

    pretty_print_check(BLACK)
  end

  def pretty_print_check(set)
    capture = king_exposed?(set)
    return '' if capture.nil?

    attacker = piece_at(capture.src)
    str = "#{set.to_s.capitalize} king is checked by #{attacker}\n"
    return str if str.length > 62

    str.rjust((62 - str.length) / 2 + str.length)
  end
end
