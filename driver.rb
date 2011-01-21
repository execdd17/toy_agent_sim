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
			
				options = getMoveOptions(i,j,@board.matrix)
			
				calcMoveMeth = case col
					when Sheep, Wolf : col.method(:evaluateMoves)
				end

				# Make sure we don't invoke a string... ;)
				if Method === calcMoveMeth then
					result = calcMoveMeth.call(options)
				else
					puts "Skipping to next iteration"
					next
				end
				j+= 1
			end
			i+=1
		end
		processed = []
		i,j = 0,0
	end

	def getMoveOptions(row,column,board)
		options = []
		
		# Look UP, DOWN, LEFT, RIGHT and add to array if valid
		(row-1 < 0			? false : true) ? options << "UP" : nil
		(row+1 > board[0].length 	? false : true) ? options << "DOWN" : nil
		(column-1 < 0			? false : true) ? options << "LEFT" : nil
		(column+1 > board.length	? false : true) ? options << "RIGHT" : nil
	end
end		
