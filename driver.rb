require 'board.rb'

class SimDriver

	def initialize(boardRows=nil,boardColumns=nil)
		# NOTE: Those parens are critical
		# The logic changes without them...See if you can spot it
		@board = (boardRows and boardColumns) ? Board.new(boardRows,BoardColumns) : Board.new()
		@board.populate()
	end

	def runSim()
		processed = []
		i,j = 0,0

		@board.matrix.each do |row|
			row.each do |col|

				if processed.index(col) then 
					next
				else
					processed << col
				end
			
				@board.printBoard

				options = getMoveOptions(i,j,@board.matrix)
			
				calcMoveMeth = case col
					when Sheep, Wolf : col.method(:evaluateMoves)
				end

				# Make sure we don't invoke a string... ;)
				if Method === calcMoveMeth then
					puts "Sending options for [#{i}][#{j}] : #{@board.matrix[i][j]}"
					#puts "The options are #{options}"
					result = calcMoveMeth.call(options)
					puts "Result is #{result}"
				else
					puts "Skipping [#{i}][#{j}]"
					next
				end

				options = nil
				j+= 1
			end
			i+=1
		end
		processed = []
		i,j = 0,0
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
		# I could have a lso just used >= and <= too
		(row-1 < 0			? true : false) ? nil : (options[:UP]    = board[row-1][column])
		(row+1 > board.length-1	 	? true : false) ? nil : (options[:DOWN]  = board[row+1][column])
		(column-1 < 0			? true : false) ? nil : (options[:LEFT]  = board[row][column-1])
		(column+1 > board.length-1	? true : false) ? nil : (options[:RIGHT] = board[row][column+1])

		return options
	end
end	

s = SimDriver.new
s.runSim

[[['a','b'] , ['c','d'] ] , [['e','f'], ['g','h']]]	
