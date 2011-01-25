=begin
 This Class Represents the Wolf Agent in an Agent Based Simulation.
 I would like this agent to interact with other wolves, grass, and sheep

 Written By:
 Alexander Vanadio
=end
class Wolf
        
	# The idea of energy might be interesting to implement
        # For now, let's assume that everything can move if it
        # has the desire to
        TOTAL_ENERGY    = 10
        MOVE_COST       = 1

        # Determine what move is best. First loop looks for sheep and returns if found
        # second loop returns anything that isn't another wolf
        # last return statement handles the case where there is no move to make
	def evaluateMoves(options)
		puts "Wolf Movement Options:"
    options.each { |move| p "I can go #{move}" }
    
    sensibleMoves = []

    # Check if there are any sheep nearby and return one at random if there are some
		options.each { |move| sensibleMoves << move[0] if Sheep === move[1]}
    result = sensibleMoves.length == 0 ? nil : sensibleMoves[(rand*100).to_i % sensibleMoves.length]
    return result if result 
    
    # Add moves that will not lead to a spot that is occupied by a wolf already to array
		options.each { |move| sensibleMoves << move[0] unless Wolf === move[1]}
    
    # Return a random move in the array or nil of array is empty
    sensibleMoves.length == 0 ? nil : sensibleMoves[(rand*100).to_i % sensibleMoves.length]
  end

        # Move the wolf to that location on the grid
        def move(direction)

        end
end
