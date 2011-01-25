require 'board.rb'

class SimDriver

  NUM_ROUNDS = 1
  ROW, COL = 3,3

	def initialize(boardRows=nil,boardColumns=nil)
		# NOTE: Those parens are critical
		# The logic changes without them...See if you can spot it
		@board = (boardRows and boardColumns) ? Board.new(boardRows,BoardColumns) : Board.new()
		@board.populate()
	end

	def runSim()
		processed = []
		i,j = 0,0
   

    (0...NUM_ROUNDS).each do
      puts "New Round"
      (i...ROW).each do
        (j...COL).each do
  		#@board.matrix.each do |row|
  			#row.each do |col|
          gridObject = @board.matrix[i][j]
          if not gridObject then
              j+=1
              next
          end
  
  				if processed.index(gridObject) then
  					puts "Already processed [#{gridObject}]"
            j+=1
  					next
  				else
  					processed << gridObject
  				end
  			
  				@board.printBoard
  
  				options = getMoveOptions(i,j,@board.matrix)
  			
  				calcMoveMeth = case gridObject
  					when Sheep, Wolf then gridObject.method(:evaluateMoves)
  				end
  
  				# Make sure we don't invoke a string... ;)
  				if Method === calcMoveMeth then
  					puts "Sending options for [#{i}][#{j}] : #{@board.matrix[i][j]}"
  					#puts "The options are #{options}"
  					result = calcMoveMeth.call(options)
  					puts "Result is #{result}"
  					move(@board.matrix,i,j,result)
  				else
  					puts "Skipping [#{i}][#{j}]"
  					next
  				end
  
  				options = nil
  				j+= 1
  			end
  			i += 1
        j  = 0
  		end
        @board.printBoard
        processed = []
        i = 0
     end
      

    
	end

	# Moves a specified agent to another location then clears its former location	
	def move(board, row, col, direction)
   
    return unless direction
    
		case direction
			when :UP     then board[row-1][col] = board[row][col]
			when :DOWN 	 then board[row+1][col] = board[row][col]
			when :LEFT   then board[row][col-1] = board[row][col]
			when :RIGHT	 then board[row][col+1] = board[row][col]
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
		(row-1 < 0                  ? true : false) ? nil : (options[:UP]    = board[row-1][column])
		(row+1 > board.length-1	 	  ? true : false) ? nil : (options[:DOWN]  = board[row+1][column])
		(column-1 < 0			          ? true : false) ? nil : (options[:LEFT]  = board[row][column-1])
		(column+1 > board.length-1	? true : false) ? nil : (options[:RIGHT] = board[row][column+1])

		return options
	end
end	

s = SimDriver.new
s.runSim
