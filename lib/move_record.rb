class MoveRecord
  attr_reader :piece, :dest

  def initialize(piece, dest)
    @piece = piece
    @dest = dest
  end
end
