class SimDriver

	def initialize(boardRows=nil,boardColumns=nil)
		# NOTE: Those parens are critical
		# The logic changes without them...See if you can spot it
		@board = (boardRows and boardColumns) ? Board.new(boardRows,BoardColumns) : Board.new()
		@board.populate()
	end

	def runSim()
		@board.matrix.each do |row|
			row.each do |col|
				print "[#{row}][#{col}]"
			end
		end
	end
end		
