require 'spec_helper'
include ToyAgentSim

describe Wolf do
  subject { Wolf.new }

  describe "#evaluate_moves" do
    it "should pick a food move as the higest priority" do
      moves = {:UP    => Wolf::FOOD_TYPES.map { |klass| klass.new }.sample,
               :DOWN  => Wolf::SAFE_TYPES.sample}
  
      subject.evaluate_moves(moves).should == :UP
    end

    it "should pick a safe move when there are no food moves" do
      moves = {:UP    => Object.new,
               :DOWN  => Wolf::SAFE_TYPES.sample}
      
      subject.evaluate_moves(moves).should == :DOWN
    end

    it "should not move when there are no food or safe moves" do
      moves = {:UP    => Object.new,
               :DOWN  => Object.new}
      
      subject.evaluate_moves(moves).should == nil
    end
  end

  describe "#animate?" do
    it "should default to false" do
      subject.animate?.should == false
    end
  end
end
