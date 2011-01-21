=begin
 This Class Represents the Wolf Agent in an Agent Based Simulation.
 I would like this agent to interact with other wolves, grass, and sheep

 Written By:
 Alexander Vanadio
=end
class Wolf

	
	# Constants representing Movement Direction
	UP 	= 0
	DOWN	= 1
	LEFT	= 2
	RIGHT	= 3

        # The idea of energy might be interesting to implement
        # For now, let's assume that everything cam move if it
        # has the desire to
        TOTAL_ENERGY    = 10
        MOVE_COST       = 1

        # Determine what the consequences are of that move
        # For example, is there grass on that space?
        # is there a sheep?
        def evaluateMoves(options)
		
        end

        # Move the wolf to that location on the grid
        def move(direction)

        end
end
