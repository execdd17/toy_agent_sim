require "./wolf.rb"
require "./sheep.rb"

class Board

  # Amount of Sheep or Wolves
  LOW,MEDIUM,HIGH = 0,1,2

  # Default Board Values
  BOARD_ROWS, BOARD_COLUMNS = 7,7

  # Board accessor (reader)
  attr_reader :matrix

  # Creates the Empty Board
  def initialize()
    @matrix = []

    BOARD_ROWS.times { @matrix << Array.new(BOARD_COLUMNS) }
  end

  # Fill in the board based on user input
  def populate(sheep=MEDIUM,wolves=LOW)
    total_grid_size = BOARD_ROWS * BOARD_COLUMNS

    num_sheep, num_wolves = [sheep, wolves].map do |e|
      case e
        when LOW    then total_grid_size / 12
        when MEDIUM then total_grid_size / 6
        when HIGH   then total_grid_size / 3
      end
    end

    place_agents(:Sheep, num_sheep)
    place_agents(:Wolf,  num_wolves)
    self.grow_grass()
  end

  def grow_grass()
    empty_spaces = num_empty_spaces()

    # Regen between 2/5 amd 3/5 of the free space with grass
    empty_spaces  = empty_spaces*(1.0/5.0) + rand((2.0/5.0)*empty_spaces)
    empty_spaces  = empty_spaces.to_i

    # Keep Putting more grass in the board until there is no room or emptySpaces is met
    while empty_spaces > 0 and self.is_space?
      i = rand(BOARD_ROWS)
      j = rand(BOARD_COLUMNS)
      empty_spaces -= 1 and @matrix[i][j] = :Grass unless @matrix[i][j]
    end
  end

  def num_empty_spaces
    num = 0
    @matrix.each { |list| list.each { |object| num+=1 if not object } }
    num
  end

  # Check if there is space to put the grass; note that grass is placed on nil spaces
  def is_space?()
    @matrix.any? do |list|
      list.any? { |item| item }
    end
  end

  # Nice Text Representation of the entire board 
  def print_board()
    oneCol = 24
    totalChars = (oneCol * BOARD_COLUMNS) - (BOARD_COLUMNS-1)
    puts "-" * totalChars

    (0...BOARD_ROWS).each do |i|
      print "|"
      (0...BOARD_COLUMNS).each do |j|
        printf(" %-20s |",@matrix[i][j])
      end
      puts
    end

    puts "-" * totalChars + "\n\n"
  end

  private

  def place_agents(type, num_agents)
    num_agents = num_agents == 0 ? 1 : num_agents

    while num_agents > 0
      i,j = rand(BOARD_ROWS),rand(BOARD_COLUMNS)

      # Skip if something is in that spot already
      next if @matrix[i][j]

      @matrix[i][j] = eval "#{type}.new"
      num_agents -= 1
    end
  end
end
