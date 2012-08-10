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

          #TODO If I am going in order from 0 to n, then why bother keeping track
          # of what I've processed?
          if processed.index(grid_object) then
            next
          else
            processed << grid_object
          end

          options = @board.get_move_options(i,j)

          #TODO: Change this to a simple Object#respond_to?
          calc_move_meth = case grid_object
            when Sheep, Wolf then grid_object.method(:evaluate_moves)
          end

          # Make sure we only invoke methods
          if Method === calc_move_meth then
            result = calc_move_meth.call(options)

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
end
