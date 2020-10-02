require './lib/king'
require './lib/testing_board'

describe King do
  let(:board) { TestingBoard.new(5, 5) }
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }
  let(:king) { King.new(board, Vector2Int.new(2, 2), white_player) }

  describe '#reachables' do
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
  end
end
