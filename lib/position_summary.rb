require_relative 'essentials'
require_relative 'board'
require_relative 'pawn'
require_relative 'king'

class PositionSummary
  include Essentials

  attr_reader :positions, :en_passant_able,
              :white_king_side_castling, :white_queen_side_castling,
              :black_king_side_castling, :black_queen_side_castling

  def initialize(board)
    @positions = nil
    @en_passant_able = nil
    @white_king_side_castling = nil
    @white_queen_side_castling = nil
    @black_king_side_castling = nil
    @black_queen_side_castling = nil

    white_pieces = board.pieces_by_set(WHITE)
    black_pieces = board.pieces_by_set(BLACK)
    pieces = white_pieces.concat(black_pieces)

    initialize_positions(pieces)
    initialize_en_passant_able(pieces)
    initialize_castling_ables(white_pieces, black_pieces)
  end

  def ==(other)
    @positions == other.positions &&
      @en_passant_able == other.en_passant_able &&
      @white_king_side_castling == other.white_king_side_castling &&
      @white_queen_side_castling == other.white_queen_side_castling &&
      @black_king_side_castling == other.black_king_side_castling &&
      @black_queen_side_castling == other.black_queen_side_castling
  end

  def eql?(other)
    hash == other.hash
  end

  def hash
    arr = []

    @positions.each do |item|
      arr << item[:piece_type]
      arr << item[:set_color]
      arr << item[:vector]
    end

    arr.concat [
      @en_passant_able,
      @white_king_side_castling,
      @white_queen_side_castling,
      @black_king_side_castling,
      @black_queen_side_castling
    ]

    arr.hash
  end

  private

  def initialize_positions(pieces)
    sorted = pieces.sort_by(&:position)
    @positions = sorted.map do |piece|
      {
        piece_type: piece.class,
        set_color: piece.owner.set,
        vector: piece.position
      }
    end
  end

  def initialize_en_passant_able(pieces)
    pawns = pieces.select { |piece| piece.is_a?(Pawn) }
    @en_passant_able = pawns.any? do |pawn|
      !pawn.en_passant_ables?.empty?
    end
  end

  def initialize_castling_ables(white_pieces, black_pieces)
    white_king = white_pieces.find { |piece| piece.is_a?(King) }
    black_king = black_pieces.find { |piece| piece.is_a?(King) }

    @white_king_side_castling = white_king.king_side_castling_right?
    @white_queen_side_castling = white_king.queen_side_castling_right?
    @black_king_side_castling = black_king.king_side_castling_right?
    @black_queen_side_castling = black_king.queen_side_castling_right?
  end
end
