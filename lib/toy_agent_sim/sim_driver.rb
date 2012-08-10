require 'thread'

class ToyAgentSim::SimDriver
  include ToyAgentSim

  attr_reader   :board
  attr_writer   :speed
  attr_writer   :continue_running
  attr_accessor :num_rounds

  def initialize
    @board            = Board.new
    @speed            = 1.0
    @num_rounds       = 100
    @continue_running = false
    @started          = false
  end

  # TODO: FIX the BUG where newly spawned agents might have a turn if they are placed
  # higher than [i][j]. Either all new agents should get a move or none of them should
  # it's probably easier to implement none do by storing all the agents in a round and 
  # then checking to see if the agent you're about to move is in that original list.
  def run_sim
    @continue_running = @started = true
    processed = []

    (0...@num_rounds).each do |round|
      puts "Round #{round}"
      (0...Board::BOARD_ROWS).each do |i|
        (0...Board::BOARD_COLUMNS).each do |j|

          Thread.stop unless continue_running? 

          grid_object = @board.matrix[i][j]
          next if grid_object.nil? or grid_object == :Grass

          # do not process the same agent twice; this happens when an agent
          # moves down (to the next row) and maybe other cases
          processed.include?(grid_object) ? next : processed << grid_object

          options = @board.get_move_options(i,j)

          if grid_object.respond_to?(:evaluate_moves) then
            result = grid_object.evaluate_moves(options)

            # Check if we should move or delete the object
            result == :delete ? @board.delete(i,j) : move(@board.matrix,i,j,result)

            # Check if the agent is ready to reproduce and handle accordingly
            # NOTE: It is important to understand that the base spawn address is where
            # the agent started NOT where it was moved. That doesn't really make sense,
            # but I didn't bother to address it.
            # TODO: Fix that...
            if grid_object.ready_to_reproduce?
              grid_object.reset_food_consumption
              @board.spawn_agents(grid_object.class,i,j) 
            end

            grid_object.decrement_life
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

  def continue_running?
    @continue_running
  end

  def started?
    @started
  end
end
