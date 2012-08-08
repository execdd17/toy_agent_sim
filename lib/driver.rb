#!/usr/bin/env ruby

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
            spawn_agents(grid_object.class,i,j) if grid_object.method(:ready_to_reproduce?).call

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

###############################################################################
# Shoes GUI Section - Creates And Manages all GUI Logic
###############################################################################
Shoes.app :width  => (Board::BOARD_COLUMNS * 155),
          :height => (Board::BOARD_ROWS * 114),
          :title  => "Calm Wolves vs. Nervous Sheep" do

  driver     = SimDriver.new
  matrix     = driver.board.matrix

  # Thread Mutex
  semaphore = Mutex.new

  # images to use
  image_base              = "../images/"
  sheep_left, sheep_right = image_base + "sheep_left.jpg", image_base + "sheep_right.jpg"
	wolf_left, wolf_right   = image_base + "wolf_left.jpg", image_base + "wolf_right.jpg"

  wolf_pics   = [wolf_right]   # only using one pic for this (change if desired)
  sheep_pics  = [sheep_left, sheep_right]
  grass       = image_base + "small_grass2.jpg"
	taz1,taz2   = image_base + "taz1.jpg", image_base + "taz2.jpg"
	desert      = image_base + "desert.jpg"

	background white

  flow :width => 1.0, :height => 40 do
    para "Speed: "

    slider do |s|
      driver.speed= [1.0 - s.fraction, 0.005].max
    end

    para "Number of rounds: "
    el = edit_line :width => 50
    el.text= driver.num_rounds.to_s

    para "Amount of sheep: "
    sheep_lb  = list_box :items => %w{Low Medium High}, :choose => "Medium", :width => 90

    para "Amount of wolves: "
    wolf_lb = list_box :items => %w{Low Medium High}, :choose => "Low", :width => 90

    button "Start", :width => 150, :margin => [10, 0, 0, 0] do
      amount_sheep, amount_wolves = sheep_lb.text.upcase, wolf_lb.text.upcase
      driver.populate_board(Board.const_get(amount_sheep), Board.const_get(amount_wolves))
      driver.num_rounds= el.text.to_i

      # This 2-D Array represents all the flows and stacks that map naturally to the matrix
      slots = []
      Board::BOARD_ROWS.times { slots << Array.new(Board::BOARD_COLUMNS) }

      # Do the initialize drawing on the board ane crate the slot array
      # that we will loop through later
      (0...Board::BOARD_ROWS).each do |row|
        flow :width => (Board::BOARD_COLUMNS * 155), :margin => 10 do
          (0...Board::BOARD_COLUMNS).each do |col|
            s = stack :width => 1.0/Board::BOARD_COLUMNS do
              case matrix[row][col]
                when Sheep  then (image sheep_pics[rand(sheep_pics.length)])
                when :Grass then (image grass)
                when Wolf   then (image wolf_pics[rand(wolf_pics.length)])
                when nil    then (image desert)
              end
            end

            slots[row][col] = s
          end
        end
      end

      # Call the driver in a new thread so we don't have to wait for it to finish
      # executing (which defeats the whole purpose)
      Thread.new { driver.run_sim }

      # Call this routine every (1 second)/(animate argument)
      # It will go through all the slots over and over again redrawing the background based on the matrix
      # This is not very efficient because we are probably making a lot of updates on unchanged data....
      # NOTE: The mutex seems to cause less screen gitters
      animate(4) do |frame|
        (0...Board::BOARD_ROWS).each do |row|
          (0...Board::BOARD_COLUMNS).each do |col|	#col represents a stack
            grid_object = matrix[row][col]
            case grid_object
              when nil    then
                semaphore.synchronize {
                  slots[row][col].clear { (image desert) }
                }
              when :Grass then
                semaphore.synchronize {
                  slots[row][col].clear { (image grass) }
                }
              when Sheep  then
                semaphore.synchronize {
                  slots[row][col].clear { (image sheep_pics[rand(sheep_pics.length)]) }
                }
              when Wolf   then
                if grid_object.animate? then
                  Thread.new {
                    (0...2).each do
                      semaphore.synchronize {
                        slots[row][col].clear { (image taz1) }
                      }
                      sleep 0.20
                      semaphore.synchronize {
                        slots[row][col].clear { (image taz2) }
                      }
                    end
                  }
                  grid_object.animate=false
                else
                  semaphore.synchronize {
                    slots[row][col].clear { (image wolf_pics[rand(wolf_pics.length)])  }
                  }
                end
            end
          end
        end
      end
    end
  end
end
