=begin
 This Class Represents the Wolf Agent in an Agent Based Simulation.
 I would like this agent to interact with other wolves, grass, and sheep

 Written By:
 Alexander Vanadio
=end
class Wolf
        
	# The idea of energy might be interesting to implement
        # For now, let's assume that everything cam move if it
        # has the desire to
        TOTAL_ENERGY    = 10
        MOVE_COST       = 1

        # Determine what move is best. First loop looks for sheep and returns if found
        # second loop returns anything that isn't another wolf
        # last return statement handles the case where there is no move to make
	def evaluateMoves(options)
		puts "Wolf Movement Options:"
                options.each { |move| p "I can go #{move}" }

		options.each { |move| return move[0] if Sheep === move[1]}
		options.each { |move| return move[0] unless Wolf === move[1]}
		return nil
        end

        # Move the wolf to that location on the grid
        def move(direction)

        end
end
