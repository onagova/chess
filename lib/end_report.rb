class EndReport
  attr_reader :locked, :winner

  def initialize(locked, winner)
    @locked = locked
    @winner = winner
  end
end
