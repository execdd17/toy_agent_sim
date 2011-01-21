require "wolf.rb"
require "sheep.rb"

class Board

	# Board accessor (reader)
	attr_reader :matrix

	# Default Board Values
	BOARD_ROWS, BOARD_COLUMNS = 2,2

	# Create the Empty Board
	def initialize(rows=BOARD_ROWS, cols=BOARD_COLUMNS)
		@matrix = []

		# Initialize Board
		# NOTE: Array.new(FixNum) creates a nil array with
		# FixNum elements
		rows.times { @matrix << Array.new(cols) }

		# Populate The Board with Agents
		self.populate()
	end

	# Fill in the board based on something
	def populate()
		@matrix[0][0] = Sheep.new
		@matrix[1][1] = Wolf.new
	end
end
