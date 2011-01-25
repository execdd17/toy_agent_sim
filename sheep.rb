=begin
 This Class Represents the Sheep Agent in an Agent Based Simulation.
 I would like this agent to interact with other sheep, grass, and wolves

 Written By:
 Alexander Vanadio
=end
class Sheep

	# The idea of energy might be interesting to implement
	# For now, let's assume that everything cam move if it
	# has the desire to
	TOTAL_ENERGY	= 10
	MOVE_COST	= 1
	
	# Determine what the consequences are of that move
	# For example, is there grass on that space?
	# is there a wolf?
	def evaluateMoves(options)
		puts "Sheep Movement Options:"
    options.each { |move| p "I can go #{move}" }
    
    sensibleMoves = []
    
    # Add moves that will not lead to certain death or occupied by sheep already to array
		options.each { |move| sensibleMoves << move[0] if not Sheep === move[1] and not Wolf === move[1] }
    
    # Return a random move in the array or nil of array is empty
    sensibleMoves.length == 0 ? nil : sensibleMoves[rand(sensibleMoves.length)]

	end

	# Move the sheep to that location on the grid
	def move(direction)

	end
end	
