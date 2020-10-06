require_relative 'essentials'
require_relative 'vector_2_int'
require_relative 'string'
require_relative 'custom_error'
require_relative 'king'

class Board
  attr_accessor :last_move

  def initialize
    @pieces = []
    @last_move = nil
    @col_count = 8
    @row_count = 8
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
    nil
  end

  def attack_positions(set)
    pieces_by_set(set).reduce([]) { |a, v| a.concat(v.attack_positions) }
  end

  def pretty_print
    str = pretty_print_files_header
    (@row_count - 1).downto(0) { |n| str += pretty_print_rank(n) }
    str + pretty_print_files_header
  end

  private

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
end
