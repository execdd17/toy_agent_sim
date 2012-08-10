class ToyAgentSim::Board
  include ToyAgentSim

  # Amount of Sheep or Wolves
  LOW,MEDIUM,HIGH = 0,1,2

  # Default Board Values
  BOARD_ROWS, BOARD_COLUMNS = 7,7

  # Board accessor (reader)
  attr_reader :matrix

  # Creates the Empty Board
  def initialize
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

    place_agents(Sheep, num_sheep)
    place_agents(Wolf,  num_wolves)
    self.grow_grass()
  end

  def grow_grass
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

  # Check if there is space to put the grass; note that grass is placed on nil spaces
  def is_space?
    @matrix.any? do |list|
      list.any? { |item| item }
    end
  end

  # In order to spawn new agents of the same type "agent", I call getEmptyLocations 
  # to determine which nearby cells can be populated with it. 
  def spawn_agents(agent,row,col)
    return nil unless nearby_free = get_empty_locations(row,col)

    nearby_free.each do |direction|
      case direction
        when :UP        then @matrix[row-1][col] = agent.new
        when :DOWN      then @matrix[row+1][col] = agent.new
        when :LEFT      then @matrix[row][col-1] = agent.new
        when :RIGHT     then @matrix[row][col+1] = agent.new
      end
    end
  end
  
  # Look UP, DOWN, LEFT, RIGHT and add to array if valid
  # NOTE: Think of it as.. Is it illegal? True or False; the -1 offset is important
  # If False add to hash array if true return nil
  # I'm indexing into a 2x2 array, for example, 
  # so a.length == a[0].length == a[1].length == 2 BUT
  # I need to see if it's greater than 1, for example, because 
  # that is the highest index (not 2)
  # I could have a just used >= and <= too
  def get_move_options(row,column)
    options = {}

    (row-1    < 0              	  ? true : false) ? nil : (options[:UP]    = @matrix[row-1][column])
    (row+1    > @matrix.length-1  ? true : false) ? nil : (options[:DOWN]  = @matrix[row+1][column])
    (column-1 < 0			            ? true : false) ? nil : (options[:LEFT]  = @matrix[row][column-1])
    (column+1 > @matrix.length-1	? true : false) ? nil : (options[:RIGHT] = @matrix[row][column+1])

    options
  end

  # Simple delete method to clear a space on the board
  def delete(row, col)
    @matrix[row][col] = nil
  end
  
  # Nice Text Representation of the entire board 
  def print_board
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
  
  # This will return a list of directions corresponding to empty cell locations
  # adjacent to [row][col]. It uses getMoveOptions to eliminate illegal moves, and
  # then searches through them to eliminate any directions with agents already
  # in them.
  def get_empty_locations(row,col)
    options = get_move_options(row,col)
    return nil unless options.length > 0

    options.inject(Array.new) do |memo, option| 
      case option[1]
        when Sheep, Wolf then nil
      else
        memo << option[0]
      end

      memo
    end
  end

  def place_agents(agent, num_agents)
    num_agents = num_agents == 0 ? 1 : num_agents

    while num_agents > 0
      i,j = rand(BOARD_ROWS),rand(BOARD_COLUMNS)

      # Skip if something is in that spot already
      next if @matrix[i][j]

      @matrix[i][j] = agent.new
      num_agents -= 1
    end
  end
  
  def num_empty_spaces
    num = 0
    @matrix.each { |list| list.each { |object| num+=1 if not object } }
    num
  end
end
