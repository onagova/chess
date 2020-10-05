require './lib/king'
require './lib/pawn'
require './lib/testing_board'

describe King do
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }

  describe '#reachables' do
    let(:board) { TestingBoard.new(5, 5) }
    let(:king) { King.new(board, Vector2Int.new(2, 2), white_player) }
    let(:surround_positions) do
      [
        Vector2Int.new(1, 1),
        Vector2Int.new(1, 2),
        Vector2Int.new(1, 3),
        Vector2Int.new(2, 1),
        Vector2Int.new(2, 3),
        Vector2Int.new(3, 1),
        Vector2Int.new(3, 2),
        Vector2Int.new(3, 3)
      ]
    end

    it 'lists normal moves correctly' do
      board.pieces = [king]

      reachables = king.reachables
      dests = reachables.map(&:dest)
      expected = surround_positions

      expect(reachables.size).to eq(expected.size)
      expect(reachables.all? { |v| v.is_a?(MoveRecord) }).to be(true)
      expect(dests.all? { |v| expected.include?(v) }).to be(true)
    end

    it 'lists capture moves correctly' do
      pieces = [king]
      surround_positions.each do |pos|
        pieces << Piece.new(board, pos, black_player)
      end
      board.pieces = pieces

      reachables = king.reachables
      dests = reachables.map(&:dest)
      expected = surround_positions

      expect(reachables.size).to eq(expected.size)
      expect(reachables.all? { |v| v.is_a?(CaptureRecord) }).to be(true)
      expect(dests.all? { |v| expected.include?(v) }).to be(true)
    end

    it 'does not list blocked move' do
      pieces = [king]
      surround_positions.each do |pos|
        pieces << Piece.new(board, pos, white_player)
      end
      board.pieces = pieces

      expect(king.reachables.size).to eq(0)
    end

    context 'when dealing with castling' do
      let(:board) { TestingBoard.new(8, 8) }
      let(:king) { King.new(board, Vector2Int.new(4, 0), white_player) }
      let(:king_side_rook) { Rook.new(board, Vector2Int.new(7, 0), white_player) }
      let(:queen_side_rook) { Rook.new(board, Vector2Int.new(0, 0), white_player) }

      it 'lists castling correctly' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }
        king_side_castling = castling.find { |v| v.rook == king_side_rook }
        queen_side_castling = castling.find { |v| v.rook == queen_side_rook }

        expect(king_side_castling.dest).to eq(Vector2Int.new(6, 0))
        expect(king_side_castling.rook_dest).to eq(Vector2Int.new(5, 0))
        expect(queen_side_castling.dest).to eq(Vector2Int.new(2, 0))
        expect(queen_side_castling.rook_dest).to eq(Vector2Int.new(3, 0))
      end

      it 'does not list castling when rooks are missing' do
        pieces = [king]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when rooks have moved' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook
        ]
        board.pieces = pieces
        king_side_rook.instance_variable_set(:@has_moved, true)
        queen_side_rook.instance_variable_set(:@has_moved, true)

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when king has moved' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook
        ]
        board.pieces = pieces
        king.instance_variable_set(:@has_moved, true)

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when rook destination is occupied' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook,
          Piece.new(board, Vector2Int.new(5, 0), white_player),
          Piece.new(board, Vector2Int.new(3, 0), white_player)
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when king destination is occupied' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook,
          Piece.new(board, Vector2Int.new(6, 0), white_player),
          Piece.new(board, Vector2Int.new(2, 0), white_player)
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when king is attacked' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook,
          Pawn.new(board, Vector2Int.new(5, 1), black_player)
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when rook destination is attacked' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook,
          Pawn.new(board, Vector2Int.new(4, 1), black_player)
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end

      it 'does not list castling when king destination is attacked' do
        pieces = [
          king,
          king_side_rook,
          queen_side_rook,
          Pawn.new(board, Vector2Int.new(3, 1), black_player),
          Pawn.new(board, Vector2Int.new(5, 1), black_player)
        ]
        board.pieces = pieces

        castling = king.reachables.select { |v| v.is_a?(CastlingRecord) }

        expect(castling).to eq([])
      end
    end
  end
end
