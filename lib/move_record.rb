class MoveRecord
  attr_reader :piece_type, :src, :dest

  def initialize(piece_type, src, dest)
    @piece_type = piece_type
    @src = src
    @dest = dest
  end
end
