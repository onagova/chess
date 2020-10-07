class Player
  attr_reader :set

  def initialize(set)
    @set = set
  end

  def next_command(_); end

  def accept_draw; end
end
