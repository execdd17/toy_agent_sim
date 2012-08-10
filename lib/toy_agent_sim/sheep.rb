class ToyAgentSim::Sheep < ToyAgentSim::Agent
  include ToyAgentSim

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
