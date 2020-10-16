require './lib/testing_board'
require './lib/pieces/knight'
require './lib/players/player'

describe Knight do
  let(:board) { TestingBoard.new(5, 5) }
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }
  let(:knight) { Knight.new(board, Vector2Int.new(2, 2), white_player) }

  describe '#reachables' do
    let(:unreachable_positions) do
      [
        Vector2Int.new(0, 0),
        Vector2Int.new(0, 2),
        Vector2Int.new(0, 4),
        Vector2Int.new(1, 1),
        Vector2Int.new(1, 2),
        Vector2Int.new(1, 3),
        Vector2Int.new(2, 0),
        Vector2Int.new(2, 1),
        Vector2Int.new(2, 3),
        Vector2Int.new(2, 4),
        Vector2Int.new(3, 1),
        Vector2Int.new(3, 2),
        Vector2Int.new(3, 3),
        Vector2Int.new(4, 0),
        Vector2Int.new(4, 2),
        Vector2Int.new(4, 4)
      ]
    end
    let(:reachable_positions) do
      [
        Vector2Int.new(0, 1),
        Vector2Int.new(0, 3),
        Vector2Int.new(1, 0),
        Vector2Int.new(1, 4),
        Vector2Int.new(3, 0),
        Vector2Int.new(3, 4),
        Vector2Int.new(4, 1),
        Vector2Int.new(4, 3)
      ]
    end

    it 'lists normal moves correctly' do
      pieces = [knight]
      unreachable_positions.each do |pos|
        pieces << Piece.new(board, pos, white_player)
      end
      board.pieces = pieces

      reachables = knight.reachables
      dests = reachables.map(&:dest)
      expected = reachable_positions

      expect(reachables.size).to eq(expected.size)
      expect(reachables.all? { |v| v.is_a?(MoveRecord) }).to be(true)
      expect(dests.all? { |v| expected.include?(v) }).to be(true)
    end

    it 'lists capture moves correctly' do
      pieces = [knight]
      unreachable_positions.each do |pos|
        pieces << Piece.new(board, pos, white_player)
      end
      reachable_positions.each do |pos|
        pieces << Piece.new(board, pos, black_player)
      end
      board.pieces = pieces

      reachables = knight.reachables
      dests = reachables.map(&:dest)
      expected = reachable_positions

      expect(reachables.size).to eq(expected.size)
      expect(reachables.all? { |v| v.is_a?(CaptureRecord) }).to be(true)
      expect(dests.all? { |v| expected.include?(v) }).to be(true)
    end

    it 'does not list blocked move' do
      pieces = [knight]
      unreachable_positions.each do |pos|
        pieces << Piece.new(board, pos, black_player)
      end
      reachable_positions.each do |pos|
        pieces << Piece.new(board, pos, white_player)
      end
      board.pieces = pieces

      expect(knight.reachables.size).to eq(0)
    end
  end
end
