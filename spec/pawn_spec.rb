require './lib/testing_board'
require './lib/pieces/pawn'
require './lib/players/player'

describe Pawn do
  let(:board) { TestingBoard.new(5, 5) }
  let(:white_player) { Player.new(Essentials::WHITE) }
  let(:black_player) { Player.new(Essentials::BLACK) }
  let(:pawn) { Pawn.new(board, Vector2Int.new(2, 2), white_player) }

  describe '#reachables' do
    it 'lists moves correctly when reachable' do
      en_passant_dest = Vector2Int.new(3, 2)
      en_passant_piece = Pawn.new(board, en_passant_dest, black_player)

      board.move_history << EnPassantTriggerRecord.new(Vector2Int.new(3, 4), en_passant_dest)
      board.pieces = [
        pawn,
        en_passant_piece,
        Piece.new(board, Vector2Int.new(1, 3), black_player)
      ]

      reachables = pawn.reachables.map(&:dest)
      expected = [
        Vector2Int.new(2, 3),
        Vector2Int.new(2, 4),
        Vector2Int.new(1, 3),
        Vector2Int.new(3, 3)
      ]

      expect(reachables.size).to eq(expected.size)
      expect(reachables.all? { |v| expected.include?(v) }).to be(true)
    end

    context 'when advance move is unreachable' do
      it 'lists moves correctly' do
        board.pieces = [
          pawn,
          Piece.new(board, Vector2Int.new(2, 3), black_player)
        ]

        expect(pawn.reachables).to eq([])
      end
    end

    context 'when double advance move is unreachable' do
      let(:dest) { Vector2Int.new(2, 4) }

      it 'lists moves correctly when destination is occupied' do
        board.pieces = [
          pawn,
          Piece.new(board, dest, black_player)
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest)
      end

      it 'lists moves correctly when inbetween is occupied' do
        board.pieces = [
          pawn,
          Piece.new(board, Vector2Int.new(2, 3), black_player)
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest)
      end

      it 'lists moves correctly when the pawn has moved' do
        pawn.instance_variable_set(:@has_moved, true)

        board.pieces = [pawn]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest)
      end
    end

    context 'when capture move is unreachable' do
      let(:dest1) { Vector2Int.new(1, 3) }
      let(:dest2) { Vector2Int.new(3, 3) }

      it 'lists moves correctly when capture target is an ally' do
        board.pieces = [
          pawn,
          Piece.new(board, dest1, white_player),
          Piece.new(board, dest2, white_player)
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest1)
        expect(reachables).not_to include(dest2)
      end

      it 'lists moves correctly when capture target is empty' do
        board.pieces = [
          pawn
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest1)
        expect(reachables).not_to include(dest2)
      end
    end

    context 'when en passant move is unreachable' do
      let(:dest) { Vector2Int.new(3, 3) }

      it 'lists moves correctly when en passant target is an ally' do
        en_passant_dest = Vector2Int.new(3, 4)
        en_passant_piece = Pawn.new(board, en_passant_dest, white_player)

        board.move_history << EnPassantTriggerRecord.new(Vector2Int.new(3, 2), en_passant_dest)
        board.pieces = [
          pawn,
          en_passant_piece
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest)
      end

      it 'lists moves correctly when en passant target is blocked' do
        en_passant_dest = Vector2Int.new(3, 2)
        en_passant_piece = Pawn.new(board, en_passant_dest, black_player)

        board.move_history << EnPassantTriggerRecord.new(Vector2Int.new(3, 4), en_passant_dest)
        board.pieces = [
          pawn,
          en_passant_piece,
          Piece.new(board, dest, white_player)
        ]

        reachables = pawn.reachables.map(&:dest)
        expect(reachables).not_to include(dest)
      end
    end

    context 'when trigger an en passant' do
      it 'lists en passant trigger correctly when adjacent is an enemy pawn' do
        board.pieces = [
          pawn,
          Pawn.new(board, Vector2Int.new(3, 4), black_player)
        ]

        reachables = pawn.reachables
        expect(reachables.one? { |v| v.is_a?(EnPassantTriggerRecord) }).to be(true)
      end

      it 'does not list en passant trigger when adjacent is an ally pawn' do
        board.pieces = [
          pawn,
          Pawn.new(board, Vector2Int.new(3, 4), white_player)
        ]

        reachables = pawn.reachables
        expect(reachables.none? { |v| v.is_a?(EnPassantTriggerRecord) }).to be(true)
      end

      it 'does not list en passant trigger when adjacent is not a pawn' do
        board.pieces = [
          pawn,
          Piece.new(board, Vector2Int.new(3, 4), black_player)
        ]

        reachables = pawn.reachables
        expect(reachables.none? { |v| v.is_a?(EnPassantTriggerRecord) }).to be(true)
      end
    end
  end

  describe '#move' do
    it 'promotes the pawn when moves into the edge of board' do
      player_double = instance_double('Player')
      allow(player_double).to receive(:set).and_return(Essentials::WHITE)
      allow(player_double).to receive(:promote).and_return(Queen)

      pawn = Pawn.new(board, Vector2Int.new(2, 3), player_double)
      board.pieces = [pawn]

      dest = Vector2Int.new(2, 4)
      pawn.move(dest)

      expect(board.piece_at(dest).class).to be(Queen)
    end
  end
end
