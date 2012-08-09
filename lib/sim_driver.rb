require './board.rb'
require 'thread'

class SimDriver

  attr_reader   :board
  attr_writer   :speed
  attr_accessor :num_rounds

  def initialize
    @board = Board.new
    @speed = 1.0
    @num_rounds = 100
  end

  # TODO: FIX the BUG where newly spawned agents might have a turn if they are placed
  # higher than [i][j]. Either all new agents should get a move or none of them should
  # it's probably easier to implement none do by storing all the agents in a round and 
  # then checking to see if the agent you're about to move is in that original list.
  def run_sim()
    processed = []

    (0...@num_rounds).each do |round|
      puts "Round #{round}"
      (0...Board::BOARD_ROWS).each do |i|
        (0...Board::BOARD_COLUMNS).each do |j|
          grid_object = @board.matrix[i][j]
          next if not grid_object

          if processed.index(grid_object) then
            next
          else
            processed << grid_object
          end

          options = get_move_options(i,j,@board.matrix)

          calc_move_meth = case grid_object
            when Sheep, Wolf then grid_object.method(:evaluate_moves)
          end

          # Make sure we only invoke methods
          if Method === calc_move_meth then
            result = calc_move_meth.call(options)

            # Check if we should move or delete the object
            result == :delete ? delete(@board.matrix,i,j) : move(@board.matrix,i,j,result)

            # Check if the agent is ready to reproduce and handle accordingly
            # NOTE: It is important to understand that the base spawn address is where
            # the agent started NOT where it was moved. That doesn't really make sense,
            # but I didn't bother to address it.
            # TODO: Fix that...
            if grid_object.ready_to_reproduce?
              grid_object.reset_food_consumption
              spawn_agents(grid_object.class,i,j) 
            end

            # Decrement the agent's life
            grid_object.current_life=(grid_object.current_life-1)
          else
            next
          end

          options = nil
          sleep(@speed)
        end
      end

      @board.grow_grass()
      processed = []
    end
  end

  def populate_board(*args)
    @board.populate(*args)
  end

  # In order to spawn new agents of the same type "agent", I call getEmptyLocations 
  # to determine which nearby cells can be populated with it. 
  def spawn_agents(agent,row,col)
    board = @board.matrix
    return nil unless nearby_free = self.get_empty_locations(row,col,board)

    nearby_free.each do |direction|
      case direction
        when :UP        then board[row-1][col] = agent.new
        when :DOWN      then board[row+1][col] = agent.new
        when :LEFT      then board[row][col-1] = agent.new
        when :RIGHT     then board[row][col+1] = agent.new
      end
    end
  end

  # This will return a list of directions corresponding to empty cell locations
  # adjacent to [i][j]. It uses getMoveOptions to eliminate illegal moves, and
  # then searches through them to eliminate any directions with agents already
  # in them.
  def get_empty_locations(i,j,board)
    options = get_move_options(i,j,board)
    return nil unless options.length > 0

    calcMoveMeth = []
    options.each do |option| 
      case option[1]
        when Sheep, Wolf then nil
      else
        calcMoveMeth << option[0]
      end
    end

    calcMoveMeth
  end

  # Simple delete method to clear a space on the board
  def delete(board,i,j)
    board[i][j] = nil
  end

  # Moves a specified agent to another location then clears its former location	
  def move(board, row, col, direction)

    return unless direction

    case direction
      when :UP	  then board[row-1][col] = board[row][col]
      when :DOWN	then board[row+1][col] = board[row][col]
      when :LEFT	then board[row][col-1] = board[row][col]
      when :RIGHT	then board[row][col+1] = board[row][col]
    end

    board[row][col] = nil
  end

  def get_move_options(row,column,board)
    options = {}

    # Look UP, DOWN, LEFT, RIGHT and add to array if valid
    # NOTE: Think of it as.. Is it illegal? True or False; the -1 offset is important
    # If False add to hash array if true return nil
    # I'm indexing into a 2x2 array, for example, 
    # so a.length == a[0].length == a[1].length == 2 BUT
    # I need to see if it's greater than 1, for example, because 
    # that is the highest index (not 2)
    # I could have a just used >= and <= too
    (row-1    < 0              	? true : false) ? nil : (options[:UP]    = board[row-1][column])
    (row+1    > board.length-1  ? true : false) ? nil : (options[:DOWN]  = board[row+1][column])
    (column-1 < 0			          ? true : false) ? nil : (options[:LEFT]  = board[row][column-1])
    (column+1 > board.length-1	? true : false) ? nil : (options[:RIGHT] = board[row][column+1])

    options
  end
end
