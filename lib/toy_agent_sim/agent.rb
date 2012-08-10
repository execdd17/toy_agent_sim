class ToyAgentSim::Agent
  include ToyAgentSim

  def initialize
    @current_consumed = 0
    @current_life     = self.class::TOTAL_LIFE
  end

  def ready_to_reproduce?
    self.class::REQUIRED_TO_REPRODUCE <= @current_consumed
  end
  
  # organizes possible moves that an agent can take and picks the best one
  def evaluate_moves_helper(options)

    return :delete unless alive?

    sensible_moves = {:food => [], :safe => []}

    # Find the possible moves that the agent can take
    options.each do |move| 
      sensible_moves[:food] << move[0] if self.class::FOOD_TYPES.any? { |type| type  === move[1] }
      sensible_moves[:safe] << move[0] if self.class::SAFE_TYPES.any? { |type| type  === move[1] }
    end

    # the agent prefers to move when possible, choosing food first and then non-food;
    # the agent will choose to do nothing if that is the only safe option
    if sensible_moves[:food].size > 0 then
      @current_consumed     += 1
      @current_life         += 1
      selected_move         = sensible_moves[:food].sample

      yield if block_given?         # any additional processing
    elsif sensible_moves[:safe].size > 0 then
      selected_move         = sensible_moves[:safe].sample  
    else
      selected_move         = nil   # don't move anywhere
    end

    selected_move
  end

  def decrement_life(amount=1)
    @current_life -=amount
  end

  def reset_food_consumption
    @current_consumed = 0
  end

  private

  def alive?
    @current_life > 0
  end
end
