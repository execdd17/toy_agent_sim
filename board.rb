require "./wolf.rb"
require "./sheep.rb"

class Board

	# Amount of Sheep or Wolves
	LOW,MEDIUM,HIGH = 0,1,2

  # Default Board Values
  BOARD_ROWS, BOARD_COLUMNS = 10,10

	# Board accessor (reader)
	attr_reader :matrix

	# Creates the Empty Board
	def initialize()
		@matrix = []

		# NOTE: Array.new(FixNum) creates a nil array with FixNum elements
		BOARD_ROWS.times { @matrix << Array.new(BOARD_COLUMNS) }

		# Populate The Board with Agents
		self.populate()
	end

	# Fill in the board based on user input
	def populate(sheep=MEDIUM,wolves=LOW)
		totalGridSize = BOARD_ROWS * BOARD_COLUMNS

    num_sheep, num_wolves = [sheep, wolves].map do |e|
      case e
        when LOW    then totalGridSize / 12
        when MEDIUM then totalGridSize / 6
        when HIGH   then totalGridSize / 3
      end
    end

		place_agents(:Sheep, num_sheep)
    place_agents(:Wolf,  num_wolves)
    self.growGrass()
	end

	def growGrass()
		emptySpaces = numEmptySpaces()

		# Regen between 2/5 amd 3/5 of the free space with grass
		numGrass  = emptySpaces*(1.0/5.0) + rand((2.0/5.0)*emptySpaces)
    numGrass  = numGrass.to_i

		# Keep Putting more grass in the board until there is no room or numGrass is met
		while numGrass > 0 and self.isSpace?
			i = rand(BOARD_ROWS)
			j = rand(BOARD_COLUMNS)
			numGrass -= 1 and @matrix[i][j] = :Grass unless @matrix[i][j]
		end
	end

	def numEmptySpaces
		num = 0
		@matrix.each { |list| list.each { |object| num+=1 if not object } }
		num
	end

	# Check if there is space to put the grass
	def isSpace?()
		@matrix.each { |list| list.each { |item| if not item then isSpace = true end } }
	end

	# Nice Text Representation of the entire board 
	def printBoard()
		oneCol = 24
		totalChars = (oneCol * BOARD_COLUMNS) - (BOARD_COLUMNS-1)
		puts "-" * totalChars
		
		(0...BOARD_ROWS).each do |i|
			print "|"
			(0...BOARD_COLUMNS).each do |j|
				printf(" %-20s |",@matrix[i][j])
			end
			puts
		end
		puts "-" * totalChars + "\n\n"
  end

  private

  def place_agents(type, num_agents)
    num_agents = num_agents == 0 ? 1 : num_agents

    while num_agents > 0
      i,j = rand(BOARD_ROWS),rand(BOARD_COLUMNS)

      # Skip if something is in that spot already
      next if @matrix[i][j]

      @matrix[i][j] = eval "#{type}.new"
      num_agents -= 1
    end
  end
end
