require "./toy_agent_sim"
include ToyAgentSim

Shoes.app :width  => (Board::BOARD_COLUMNS * 150),
          :height => (Board::BOARD_ROWS * 114),
          :title  => "Calm Wolves vs. Nervous Sheep" do

  driver     = SimDriver.new
  matrix     = driver.board.matrix

  # Thread Mutex
  semaphore = Mutex.new

  # images to use
  image_base              = "../images/"
  sheep_left, sheep_right = image_base + "sheep_left.jpg", image_base + "sheep_right.jpg"
  wolf_left, wolf_right   = image_base + "wolf_left.jpg", image_base + "wolf_right.jpg"

  wolf_pics   = [wolf_right]   # only using one pic for this (change if desired)
  sheep_pics  = [sheep_left, sheep_right]
  grass       = image_base + "small_grass2.jpg"
  taz1,taz2   = image_base + "taz1.jpg", image_base + "taz2.jpg"
  desert      = image_base + "desert.jpg"
  
  background white

  flow :width => 1.0, :height => 40 do
    
    para "Number of rounds: "
    el = edit_line :width => 50
    el.text= driver.num_rounds.to_s

    para "Amount of sheep: "
    sheep_lb  = list_box :items => %w{Low Medium High}, :choose => "Medium", :width => 90

    para "Amount of wolves: "
    wolf_lb = list_box :items => %w{Low Medium High}, :choose => "Low", :width => 90
    
    para "Speed: "

    slider :width => 100 do |s|
      driver.speed= [1.0 - s.fraction, 0.005].max
    end

    button "Start", :width => 80, :margin => [10, 0, 0, 0] do

      unless driver.started?
        amount_sheep, amount_wolves = sheep_lb.text.upcase, wolf_lb.text.upcase
        
        driver.populate_board(Board.const_get(amount_sheep), Board.const_get(amount_wolves))
        driver.num_rounds= el.text.to_i

        # This 2-D Array represents all the flows and stacks that map naturally to the matrix
        slots = []
        Board::BOARD_ROWS.times { slots << Array.new(Board::BOARD_COLUMNS) }

        # Do the initialize drawing on the board ane crate the slot array
        # that we will loop through later
        (0...Board::BOARD_ROWS).each do |row|
          flow :width => (Board::BOARD_COLUMNS * 155), :margin => 10 do
            (0...Board::BOARD_COLUMNS).each do |col|
              s = stack :width => 1.0/Board::BOARD_COLUMNS do
                case matrix[row][col]
                  when Sheep  then image sheep_pics.sample
                  when :Grass then image grass
                  when Wolf   then image wolf_pics.sample
                  when nil    then image desert
                end
              end

              slots[row][col] = s
            end
          end
        end

        # Call the driver in a new thread so we don't have to wait for it to finish
        # executing (which defeats the whole purpose)
        @sim_thread = Thread.new { driver.run_sim }

        # Call this routine every (1 second)/(animate argument)
        # It will go through all the slots over and over again redrawing the background based on the matrix
        # This is not very efficient because we are probably making a lot of updates on unchanged data....
        # NOTE: The mutex seems to cause less screen gitters
        animate(4) do |frame|
          (0...Board::BOARD_ROWS).each do |row|
            (0...Board::BOARD_COLUMNS).each do |col|	#col represents a stack
              grid_object = matrix[row][col]
              case grid_object
                when nil    then
                  semaphore.synchronize {
                    slots[row][col].clear { image desert }
                  }
                when :Grass then
                  semaphore.synchronize {
                    slots[row][col].clear { image grass }
                  }
                when Sheep  then
                  semaphore.synchronize {
                    slots[row][col].clear { image sheep_pics.sample }
                  }
                when Wolf   then
                  if grid_object.animate? then
                    Thread.new {
                      (0...2).each do
                        semaphore.synchronize {
                          slots[row][col].clear { image taz1 }
                        }
                        sleep 0.20
                        semaphore.synchronize {
                          slots[row][col].clear { image taz2 }
                        }
                      end
                    }
                    grid_object.animate=false
                  else
                    semaphore.synchronize {
                      slots[row][col].clear { image wolf_pics.sample  }
                    }
                  end
              end
            end
          end
        end
      end
    end

    button "Pause", :width => 80, :margin => [10, 0, 0, 0] do
      driver.continue_running = false
    end
    
    button "Resume", :width => 80, :margin => [10, 0, 0, 0] do
      driver.continue_running = true
      @sim_thread.wakeup
    end
  end
end
