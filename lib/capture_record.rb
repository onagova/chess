require './lib/move_record'

class CaptureRecord < MoveRecord
  attr_reader :captured

  def initialize(piece, dest, captured)
    super(piece, dest)
    @captured = captured
  end
end
