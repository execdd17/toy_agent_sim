class ToyAgentSim::Wolf < ToyAgentSim::Agent
  include ToyAgentSim
        
  TOTAL_LIFE   		        = 4
  REQUIRED_TO_REPRODUCE   = 4
  MOVE_COST   		        = 1
  FOOD_TYPES              = [Sheep]
  SAFE_TYPES              = [:Grass, nil]

  # the animation flag for when a wolf eats a sheep
  attr_writer :animate

  def initialize
    super
    @animate = false
  end

  def animate?
    @animate
  end

  def evaluate_moves(options)
    evaluate_moves_helper(options) { @animate = true }
  end
end
