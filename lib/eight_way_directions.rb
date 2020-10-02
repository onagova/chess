require './lib/vector_2_int.rb'

module EightWayDirections
  NON_DIAGONAL_DIRECTIONS = [
    Vector2Int.new(-1, 0),
    Vector2Int.new(0, -1),
    Vector2Int.new(0, 1),
    Vector2Int.new(1, 0)
  ].freeze

  DIAGONAL_DIRECTIONS = [
    Vector2Int.new(-1, -1),
    Vector2Int.new(-1, 1),
    Vector2Int.new(1, -1),
    Vector2Int.new(1, 1)
  ].freeze
end
