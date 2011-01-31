require 'board.rb'

class SimDriver

  NUM_ROUNDS = 500
  attr_reader :board

	def initialize(boardRows=nil,boardColumns=nil)
		# NOTE: Those parens are critical
		# The logic changes without them...See if you can spot it
		#@board = (boardRows and boardColumns) ? Board.new(boardRows,BoardColumns) : Board.new()
		
		@board = Board.new
	end

	# NOTE: For Ranges, ... is EXCLUSIVE => 0...3 will be 0,1,2
	# 0..3 is INCLUSIVE => 0,1,2,3
	# TODO: FIX the BUG where newly spawned agents might have a turn if they are placed 
	# higher than [i][j]. Either all new agents should get a move or none of them should
	# it's probably easier to implement none do by storing all the agents in a round and 
	# then checking to see if the agent you're about to move is in that original list.
	def runSim()
		processed = []

    		(0...NUM_ROUNDS).each do |round|
      			puts "Round #{round}"
      			(0...Board.BOARD_ROWS).each do |i|
        			(0...Board.BOARD_COLUMNS).each do |j|
          				gridObject = @board.matrix[i][j]
					next if not gridObject 					
 
  					if processed.index(gridObject) then
  						#puts "Already processed [#{gridObject}]"
  						next
  					else
  						processed << gridObject
	  				end
	  			
  					#@board.printBoard
 	 
  					options = getMoveOptions(i,j,@board.matrix)
  				
  					calcMoveMeth = case gridObject
  						when Sheep, Wolf then gridObject.method(:evaluateMoves)
  					end
 	 
  					# Make sure we only invoke methods
  					if Method === calcMoveMeth then
  						#puts "Sending options for [#{i}][#{j}] : #{@board.matrix[i][j]}"
  						#puts "The options are #{options}"
  						result = calcMoveMeth.call(options)
  						#puts "Result is #{result}"
	
						# Check if we should move or delete the object
						result == :delete ? delete(@board.matrix,i,j) : move(@board.matrix,i,j,result)
						
            					#@board.printBoard
            
						# Check if the agent is ready to reproduce and handle accordingly
            					# NOTE: It is important to understand that the base spawn address is where
            					# the agent started NOT where it was moved. That doesn't really make sense,
            					# but I didn't bother to address it.
            					# TODO: Fix that...
						spawnAgents(gridObject.class,i,j) if gridObject.method(:readyToReproduce?).call 
            
						# Decrement the agent's life
						gridObject.current_life=(gridObject.current_life-1)
  					else
  						#puts "Skipping [#{i}][#{j}]"
  						next
  					end
 	 
  					options = nil
					#@board.printBoard
					#print "\e[2J\e[f" #clear screen
					#sleep(0.65)
  				end
  			end
			#@board.printBoard
			@board.growGrass()
        		processed = []
     		end
	end

	# In order to spawn new agents of the same type "agent", I call getEmptyLocations 
	# to determine which nearby cells can be populated with it. 
	def spawnAgents(agent,row,col)
    		board = @board.matrix 
		return nil unless nearbyFree = self.getEmptyLocations(row,col,board)

		nearbyFree.each do |direction|
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
	def getEmptyLocations(i,j,board)
		options = getMoveOptions(i,j,board)
		return nil unless options.length > 0

		spawnLocations = []
		options.each do |option| 
			case option[1]
				when Sheep, Wolf then nil
				else
					spawnLocations << option[0]
			end
		end
	
		return spawnLocations	
	end

	# Simple delete method to clear a space on the board
	def delete(board,i,j)
		#printf("Deleting [%d][%d]\n",i,j)
		board[i][j] = nil
	end

	# Moves a specified agent to another location then clears its former location	
	def move(board, row, col, direction)
   
    		return unless direction
    
		case direction
			when :UP	then board[row-1][col] = board[row][col]
			when :DOWN	then board[row+1][col] = board[row][col]
			when :LEFT	then board[row][col-1] = board[row][col]
			when :RIGHT	then board[row][col+1] = board[row][col]
		end

		board[row][col] = nil
	end

	def getMoveOptions(row,column,board)
		options = {}
		#puts "Parameters Passed: row [#{row}], column [#{column}], board [#{board}]"		

		# Look UP, DOWN, LEFT, RIGHT and add to array if valid
		# NOTE: Think of it as.. Is it illegal? True or False
		# If False add to hash array if true return nil
		# NOTE: I SPENT HOURS DEBUGGING THIS IN ORDER TO FIND I NEEDED THE -1 OFFSET
		# I'm indexing into a 2x2 array, for example, so a.length == a[0].length == a[1].length == 2 BUT
		# I need to see if it's greater than 1, for example, because that is the highest index (not 2)
		# I could have a just used >= and <= too
		(row-1 < 0              	? true : false) ? nil : (options[:UP]    = board[row-1][column])
		(row+1 > board.length-1		? true : false) ? nil : (options[:DOWN]  = board[row+1][column])
		(column-1 < 0			? true : false) ? nil : (options[:LEFT]  = board[row][column-1])
		(column+1 > board.length-1	? true : false) ? nil : (options[:RIGHT] = board[row][column+1])

		return options
	end
end	

Shoes.app :width => 925, :height => 550 do

	@rows = Board.BOARD_ROWS
	@cols = Board.BOARD_COLUMNS
	
	background white
	
	@driver = SimDriver.new
	@board = @driver.board
	@matrix = @board.matrix

        (0...@rows).each do |row|
                flow :width => 1000, :margin => 10 do
                        (0...@cols).each do |col|
                                stack :width => 1.0/Board.BOARD_COLUMNS do
                                        #para "[#{row}] [#{col}]"
                                        case @matrix[row][col]
                                        	when Sheep  then (image "/home/tester/Downloads/small_sheep.gif")           
                                        	when :Grass then (image "/home/tester/Downloads/small_grass.jpg")
                                        	when Wolf   then (image "/home/tester/Downloads/small_wolf.gif")
                                        end
				end
			end
		end
	end
end
                                        
