=begin
 This Class Represents the Sheep Agent in an Agent Based Simulation.
 I would like this agent to interact with other sheep, grass, and wolves

 Written By:
 Alexander Vanadio
=end
class Sheep

	# The idea of energy might be interesting to implement
	# For now, let's assume that everything can move if it
	# has the desire to
	TOTAL_LIFE              = 3
	REQUIRED_TO_REPRODUCE   = 2
	MOVE_COST               = 1

	# The amount of life that the sheep currently has. This is decreased
  # whenever an agent is processed
	attr_accessor :current_life               
	
  def initialize()
		@current_life = TOTAL_LIFE
    @current_consumed = 0   # the amount of grass eaten
	end

	# Determine what the consequences are of that move
	# For example, is there grass on that space? is there a wolf?
	def evaluateMoves(options)
		
		# Check to see if the wolf has enough in him to carry on!       
		return :delete if @current_life == 0

   	sensible_moves = []

		# Check if there is  any grass nearby and return one at random if there are some
		options.each { |move| sensible_moves << move[0] if :Grass  == move[1]}
		result = sensible_moves.length == 0 ? nil : sensible_moves[rand(sensible_moves.length)]
    
		if result then
      @current_consumed += 1
			@current_life += 1	# give them a little extra survivability
      return result
    end
    
    # Add moves that will not lead to certain death or occupied by sheep already to array
		options.each { |move| sensible_moves << move[0] if not Sheep === move[1] and not Wolf === move[1] }
    
    # Return a random move in the array or nil of array is empty
    sensible_moves.length == 0 ? nil : sensible_moves[rand(sensible_moves.length)]
	end

  def readyToReproduce?()
    ready = REQUIRED_TO_REPRODUCE == @current_consumed
    ready ? (@current_consumed = 0 and true) : false
  end
end	
