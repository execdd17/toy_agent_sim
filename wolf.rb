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
  TOTAL_LIFE    		    = 4
	REQUIRED_TO_REPRODUCE	= 4
  MOVE_COST       	    = 1

	# The amount of life that the wolf currently has. This is decreased 
  # whenever an agent is processed
	attr_accessor :current_life

	# Indicator of when animation should be done (when the wolf eats a sheep)
	attr_writer :animate

	def initialize()
		@current_life = TOTAL_LIFE
    @current_consumed = 0   #the number of sheep eaten by a particular wolf
		@animate = false
	end

	# if it's ready to animate the wolf eating the sheep
	def animate?
		@animate
	end

  # Determine what move is best. First loop looks for sheep and returns if found
  # second loop returns anything that isn't another wolf
  # last return statement handles the case where there is no move to make
	def evaluate_moves(options)
   	
		# Check to see if the wolf has enough in him to carry on!	
		return :delete if @current_life == 0
		 
    sensible_moves = []

    # Check if there are any sheep nearby and return one at random if there are some
		options.each { |move| sensible_moves << move[0] if Sheep === move[1]}
    result = sensible_moves.length == 0 ? nil : sensible_moves[rand(sensible_moves.length)]
        
    if result then
      @current_consumed += 1
			@current_life += 1	# a little extra survivability
			@animate = true
      return result
    end
    
    # Add moves that will not lead to a spot that is occupied by a wolf already to array
		options.each { |move| sensible_moves << move[0] unless Wolf === move[1]}
    
    # Return a random move in the array or nil of array is empty
    sensible_moves.length == 0 ? nil : sensible_moves[rand(sensible_moves.length)]
  end

	def ready_to_reproduce?()
		ready = REQUIRED_TO_REPRODUCE == @current_consumed
		ready ? (@current_consumed = 0 and true) : false
	end
end
