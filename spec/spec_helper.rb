require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require './lib/toy_agent_sim'
