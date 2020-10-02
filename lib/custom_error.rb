class CustomError < StandardError
  def initialize(msg = '')
    super("ChessError: #{msg}")
  end
end
