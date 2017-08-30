require_relative 'msg_handler'

# handles player actions
class Player
  attr_reader :rotation_in_radians, :position, :map_limit, :board_ref

  def initialize(args)
    @rotation_in_radians = 0.5 * rand(3)
    @map_limit = args[:map_size] || 5
    @position = args[:position] || player_random_start
    @board_ref = args[:board]
  end

  def player_icon
    ICON_FOR[@rotation_in_radians]
  end

  def turn(direction)
    return unless DIR.keys.include?(direction)
    @rotation_in_radians = @rotation_in_radians.send(DIR[direction], 0.5) % 2
  end

  def forward(speed)
    vector = [
      rad_to_vect(:sin) * speed,
      rad_to_vect(:cos) * speed
    ]
    move_along(vector)
  end

  def update
    board_ref.update_player(position, player_icon)
  end

  private

  DIR = {
    left: :-,
    right: :+
  }.freeze

  ICON_FOR = {
    0.0  => '>',
    0.5  => 'v',
    1.0  => '<',
    1.5  => '^'
  }.freeze

  def player_random_start
    [rand(map_limit), rand(map_limit)]
  end

  def rad_to_vect(msg)
    Math.send(msg, Math::PI * @rotation_in_radians).to_i
  end

  def move_along(vector)
    board_ref.update_player(position)
    @position = attempt_movement(vector) || position
  end

  def attempt_movement(vector)
    new_pos = position.zip(vector).map { |x| x.reduce(:+) }
    if new_pos.all? { |x| movement_valid?(x) }
      new_pos
    else
      MsgHandler.log(msg: 'invalid', values: new_pos)
      false
    end
  end

  def movement_valid?(value)
    (0..map_limit - 1).cover?(value)
  end
end
