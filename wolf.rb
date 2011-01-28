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
        TOTAL_LIFE    		= 5
	REQUIRED_TO_REPRODUCE	= 1
        MOVE_COST       	= 1

	# The amount of life that the wolf currently has. This is decreased whenever an agent is processed
	attr_writer :current_life
	attr_reader :current_life

  # NOTE: For some reason I can't declare @current_consumed above this. It never gets initialized apparently...
	def initialize()
		@current_life = TOTAL_LIFE
    # The number of sheep eaten by a particular wolf
    @current_consumed = 0
	end

        # Determine what move is best. First loop looks for sheep and returns if found
        # second loop returns anything that isn't another wolf
        # last return statement handles the case where there is no move to make
	def evaluateMoves(options)
		#puts "Wolf Movement Options:"
    		#options.each { |move| p "I can go #{move}" }
   	
		# Check to see if the wolf has enough in him to carry on!	
		return :delete if @current_life == 0
		 
    		sensibleMoves = []

    		# Check if there are any sheep nearby and return one at random if there are some
		options.each { |move| sensibleMoves << move[0] if Sheep === move[1]}
    result = sensibleMoves.length == 0 ? nil : sensibleMoves[rand(sensibleMoves.length)]
        
    if result then
      @current_consumed += 1
      return result
    end
    
    		# Add moves that will not lead to a spot that is occupied by a wolf already to array
		options.each { |move| sensibleMoves << move[0] unless Wolf === move[1]}
    
    		# Return a random move in the array or nil of array is empty
    		sensibleMoves.length == 0 ? nil : sensibleMoves[rand(sensibleMoves.length)]
  	end

	def readyToReproduce?()
		ready = REQUIRED_TO_REPRODUCE == @current_consumed
		ready ? (@current_consumed = 0 and true) : false
	end

        # Move the wolf to that location on the grid
        def move(direction)

        end
end
