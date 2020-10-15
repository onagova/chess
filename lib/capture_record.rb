require_relative 'move_record'

class CaptureRecord < MoveRecord
  attr_reader :capture_pos

  def initialize(piece_type, src, dest, capture_pos)
    super(piece_type, src, dest)
    @capture_pos = capture_pos
  end
end
