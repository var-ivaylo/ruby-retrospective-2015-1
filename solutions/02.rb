def move(snake, direction)
  snake[1..-1].push(next_position(snake, direction))
end

def grow(snake, direction)
  snake[0..-1].push(next_position(snake, direction))
end

def new_food(food, snake, dimensions)
  positions = generate_playground(dimensions[:width], dimensions[:height])

  positions.select { |position| position_free?(position, food + snake) }.sample
end

def obstacle_ahead?(snake, *directions, dimensions)
  directions.any? do |direction|
    head = next_position(snake, direction)
    blocked = outside?(head, dimensions.values) || !position_free?(head, snake)
    snake = move(snake, direction)

    blocked
  end
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, direction, dimensions)
end

def next_position(snake, direction)
  # snake.last.map.with_index { |axis, index| axis + direction[index] }
  [snake.last, direction].transpose.map { |position| position.reduce(:+) }
end

def generate_playground(width, height)
  [*0..(width - 1)].product([*0..(height - 1)])
end

def outside?(position, dimensions)
  outside_condition = ->(axis, index) { axis >= dimensions[index] or axis < 0 }

  position.find.with_index(&outside_condition) != nil
end

def position_free?(position, occupied_positions)
  !occupied_positions.include?(position)
end