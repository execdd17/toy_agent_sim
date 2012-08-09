require './agent'
require './wolf'

=begin
 This Class Represents the Sheep Agent in an Agent Based Simulation.
 I would like this agent to interact with other sheep, grass, and wolves

 Written By:
 Alexander Vanadio
=end
class Sheep < Agent

  TOTAL_LIFE              = 3
  REQUIRED_TO_REPRODUCE   = 2
  MOVE_COST               = 1
  FOOD_TYPES              = [:Grass]
  SAFE_TYPES              = [nil]

  def initialize
    super
  end

  def evaluate_moves(options)
    evaluate_moves_helper(options)
  end
end	
