require 'spec_helper'
include ToyAgentSim

describe Sheep do
  subject { Sheep.new }

  describe "#evaluate_moves" do
    it "should pick a food move as the higest priority" do
      moves = {:UP    => Sheep::FOOD_TYPES.sample,
               :DOWN  => Sheep::SAFE_TYPES.sample}
  
      subject.evaluate_moves(moves).should == :UP
    end

    it "should pick a safe move when there are no food moves" do
      moves = {:UP    => Object.new,
               :DOWN  => Sheep::SAFE_TYPES.sample}
      
      subject.evaluate_moves(moves).should == :DOWN
    end

    it "should not move when there are no food or safe moves" do
      moves = {:UP    => Object.new,
               :DOWN  => Object.new}
      
      subject.evaluate_moves(moves).should == nil
    end
  end
end
