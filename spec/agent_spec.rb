require 'spec_helper'
include ToyAgentSim

describe "Agent" do
  context "classes" do
    before(:each) do
      @agent_classes  = [Wolf, Sheep]
    end

    it "should have total life" do
      @agent_classes.all? { |klass| klass::TOTAL_LIFE.nil?.should == false }
    end

    it "should have a required to reproduce amount" do
      @agent_classes.all? { |klass| klass::REQUIRED_TO_REPRODUCE.nil?.should == false }
    end

    it "should have a move cost" do
      @agent_classes.all? { |klass| klass::MOVE_COST.nil?.should == false }
    end

    it "should have food_types" do
      @agent_classes.all? { |klass| klass::FOOD_TYPES.nil?.should == false }
    end

    it "should have safe types" do
      @agent_classes.all? { |klass| klass::SAFE_TYPES.nil?.should == false }
    end
  end

  context "instances" do
    before(:each) do
      @agents = [Wolf.new, Sheep.new]
    end

    it "should know when they are ready to reproduce" do
      @agents.each do |agent|
        increment_consumed(agent, agent.class::REQUIRED_TO_REPRODUCE) do
          agent.ready_to_reproduce?.should == true
        end
      end
    end

    it "should know when they are not ready to reproduce" do
      @agents.each do |agent|
        increment_consumed(agent, agent.class::REQUIRED_TO_REPRODUCE - 1) do
          agent.ready_to_reproduce?.should == false
        end
      end
    end

    it "should correctly decrement their lives" do
      @agents.each do |agent|
        orig_life = agent.class::TOTAL_LIFE
        curr_life = nil

        agent.decrement_life
        agent.instance_eval { curr_life = @current_life }
        curr_life.should == orig_life - 1
      end
    end

    it "should correctly know when they are alive" do
      @agents.each do |agent| 
        agent.instance_eval { @current_life = 0 }
        agent.send(:alive?).should == false
      end
    end

    it "should correctly reset the current consumed amount" do
      @agents.each do |agent| 
        current_life = nil

        agent.reset_food_consumption
        current_life = agent.instance_eval { @current_life = 0 }
        current_life.should == 0
      end
    end
  end
end

def increment_consumed(agent, amount)
  amount.times do
    agent.instance_eval { @current_consumed += 1 }
  end
  
  yield
end
