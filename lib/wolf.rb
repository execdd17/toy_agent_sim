require './agent'
require './sheep'

=begin
 This Class Represents the Wolf Agent in an Agent Based Simulation.
 I would like this agent to interact with other wolves, grass, and sheep

 Written By:
 Alexander Vanadio
=end
class Wolf < Agent
        
  TOTAL_LIFE   		        = 4
  REQUIRED_TO_REPRODUCE   = 4
  MOVE_COST   		        = 1
  FOOD_TYPES              = [Sheep]
  SAFE_TYPES              = [:Grass, nil]

  # Indicator of when animation should be done (when the wolf eats a sheep)
  attr_writer :animate

  def initialize
    super
    @animate = false
  end

  # used to animate wolf eating sheep in shoes
  def animate?
    @animate
  end

  def evaluate_moves(options)
    evaluate_moves_helper(options) { @animate = true }
  end
end
