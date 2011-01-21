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
		options = {}

		# Look UP, DOWN, LEFT, RIGHT and add to array if valid
		# NOTE: Think of it as.. Is it illegal? True or False
		# If False add to hash array if true return nil
		(row-1 < 0			? true : false) ? nil : options[:UP]    = board[row-1][column]
		(row+1 > board[0].length 	? true : false) ? nil : options[:DOWN]  = board[row+1][column]
		(column-1 < 0			? true : false) ? nil : options[:LEFT]  = board[row][column-1]
		(column+1 > board.length	? true : false) ? nil : options[:RIGHT] = board[row][column+1]

		return options
	end
end	

s = SimDriver.new
s.runSim	
