require "wolf.rb"
require "sheep.rb"

class Board

	# Board accessor (reader)
	attr_reader :matrix

	# Default Board Values
	@@BOARD_ROWS, @@BOARD_COLUMNS = 3,3

	# Create the Empty Board
	def initialize(rows=@@BOARD_ROWS, cols=@@BOARD_COLUMNS)
		@matrix = []

		# Initialize Board
		# NOTE: Array.new(FixNum) creates a nil array with
		# FixNum elements
		rows.times { @matrix << Array.new(cols) }

		# Populate The Board with Agents
		self.populate()
	end

	# Getter for Class Method	
	def self.BOARD_ROWS
		@@BOARD_ROWS
	end
	
	# Getter for Class Method
	def self.BOARD_COLUMNS
		@@BOARD_COLUMNS
	end

	# Fill in the board based on something
	def populate()	
		@matrix[0][0] = Sheep.new
		@matrix[2][2] = Sheep.new
		@matrix[1][2] = Sheep.new
		@matrix[2][0] = Wolf.new
		@matrix[1][1] = Wolf.new
		@matrix[0][1] = Wolf.new
	end

	def printBoard()
		equal = 32
		puts "=" * equal + " BOARD " + "=" * equal
		
		(0...@@BOARD_ROWS).each do |i|
			print "|"
			(0...@@BOARD_COLUMNS).each do |j|
				printf(" %-20s |",@matrix[i][j])
			end
			puts
		end
		puts
	end
end
