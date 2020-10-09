require './lib/position_summary'
require './lib/testing_board'
require './lib/player'

describe PositionSummary do
  let(:board) { TestingBoard.new(8, 8) }
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }
  let(:white_king) { King.new(board, Vector2Int.new(4, 0), white_player) }
  let(:black_king) { King.new(board, Vector2Int.new(4, 7), black_player) }
  let(:pieces) { [white_king, black_king] }

  describe '#hash' do
    it 'returns the same value for the same position' do
      white_src = Vector2Int.new(0, 1)
      white_dest = Vector2Int.new(0, 2)
      black_src = Vector2Int.new(7, 6)
      black_dest = Vector2Int.new(7, 5)
      pieces << Rook.new(board, white_src, white_player)
      pieces << Rook.new(board, black_src, black_player)
      board.pieces = pieces

      first_summary = PositionSummary.new(board)
      board.move_piece(white_src, white_dest, white_player.set)
      board.move_piece(black_src, black_dest, black_player.set)
      board.move_piece(white_dest, white_src, white_player.set)
      board.move_piece(black_dest, black_src, black_player.set)
      second_summary = PositionSummary.new(board)

      expect(first_summary.hash).to eq(second_summary.hash)
    end

    context 'when different pieces from the same set make up the same position' do
      it 'returns the same value' do
        src0 = Vector2Int.new(0, 0)
        src1 = Vector2Int.new(1, 1)
        temp = Vector2Int.new(0, 1)
        pieces << Queen.new(board, src0, white_player)
        pieces << Queen.new(board, src1, white_player)
        board.pieces = pieces

        first_summary = PositionSummary.new(board)
        board.move_piece(src0, temp, white_player.set)
        board.move_piece(src1, src0, white_player.set)
        board.move_piece(temp, src1, white_player.set)
        second_summary = PositionSummary.new(board)

        expect(first_summary.hash).to eq(second_summary.hash)
      end
    end

    context 'when en passant opportunities are different' do
      it 'returns different values' do
        pieces << Pawn.new(board, Vector2Int.new(3, 3), white_player)
        pieces << Pawn.new(board, Vector2Int.new(4, 6), black_player)

        white_src = Vector2Int.new(0, 1)
        white_dest = Vector2Int.new(0, 2)
        black_src = Vector2Int.new(7, 6)
        black_dest = Vector2Int.new(7, 5)
        pieces << Rook.new(board, white_src, white_player)
        pieces << Rook.new(board, black_src, black_player)
        board.pieces = pieces

        board.move_piece(Vector2Int.new(3, 3), Vector2Int.new(3, 4), white_player.set)
        board.move_piece(Vector2Int.new(4, 6), Vector2Int.new(4, 4), black_player.set)

        first_summary = PositionSummary.new(board)
        board.move_piece(white_src, white_dest, white_player.set)
        board.move_piece(black_src, black_dest, black_player.set)
        board.move_piece(white_dest, white_src, white_player.set)
        board.move_piece(black_dest, black_src, black_player.set)
        second_summary = PositionSummary.new(board)

        expect(first_summary.hash).not_to eq(second_summary.hash)
      end
    end

    context 'when castling opportunities are different' do
      it 'returns different values' do
        white_src = Vector2Int.new(0, 0)
        white_dest = Vector2Int.new(0, 1)
        black_src = Vector2Int.new(7, 6)
        black_dest = Vector2Int.new(7, 5)
        pieces << Rook.new(board, white_src, white_player)
        pieces << Rook.new(board, black_src, black_player)
        board.pieces = pieces

        first_summary = PositionSummary.new(board)
        board.move_piece(white_src, white_dest, white_player.set)
        board.move_piece(black_src, black_dest, black_player.set)
        board.move_piece(white_dest, white_src, white_player.set)
        board.move_piece(black_dest, black_src, black_player.set)
        second_summary = PositionSummary.new(board)

        expect(first_summary.hash).not_to eq(second_summary.hash)
      end
    end
  end
end
