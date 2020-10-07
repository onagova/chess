require './lib/testing_board'
require './lib/player'
require './lib/knight'

describe Board do
  let(:board) { TestingBoard.new(5, 5) }
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }
  let(:white_king) { King.new(board, Vector2Int.new(0, 0), white_player) }
  let(:black_king) { King.new(board, Vector2Int.new(4, 4), black_player) }
  let(:pieces) { [white_king, black_king] }

  describe '#move_piece' do
    context 'when move does not result in an end condition' do
      it 'does not lock the board and does not record a winner' do
        src = Vector2Int.new(2, 0)
        dest = Vector2Int.new(3, 2)
        pieces << Knight.new(board, src, white_player)
        board.pieces = pieces

        board.move_piece(src, dest, white_player.set)
        report = board.end_report

        expect(report.locked).to be(false)
        expect(report.winner).to be_nil
      end
    end

    context 'when move result in a win condition' do
      it 'locks the board and records a winner' do
        src = Vector2Int.new(0, 2)
        dest = Vector2Int.new(2, 1)
        pieces << Knight.new(board, src, white_player)
        pieces << Knight.new(board, Vector2Int.new(1, 3), white_player)
        pieces << Rook.new(board, Vector2Int.new(4, 0), white_player)
        board.pieces = pieces

        board.move_piece(src, dest, white_player.set)
        report = board.end_report

        expect(report.locked).to be(true)
        expect(report.winner).to be(white_player.set)
      end
    end

    context 'when move result in a draw condition' do
      it 'locks the board and records a winner' do
        src = Vector2Int.new(2, 2)
        dest = Vector2Int.new(2, 3)
        pieces << Rook.new(board, src, white_player)
        pieces << Knight.new(board, Vector2Int.new(1, 3), white_player)
        board.pieces = pieces

        board.move_piece(src, dest, white_player.set)
        report = board.end_report

        expect(report.locked).to be(true)
        expect(report.winner).to be_nil
      end
    end
  end
end
