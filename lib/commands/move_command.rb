class MoveCommand
  attr_reader :src, :dest

  def initialize(src, dest)
    @src = src
    @dest = dest
  end
end
