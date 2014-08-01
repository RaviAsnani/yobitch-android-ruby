require "app/boot"

GRID_COLORS = ["#bf7580", "#e69688", "#ffba9a", "#ff8366", "#ff9d66", "#ffb666", "#ffcb65"]


module DisplayUtils

  # Sleep for delay seconds and then render on UI thread
  def run_on_ui_thread_with_delay(delay, &block)
    Thread.start do
      sleep(delay) if delay >= 1
      run_on_ui_thread {
        block.call
      }
    end # Thread ends
  end


  # Given a position, return the corresponding color from the GRID_COLORS
  # klass => :random||:positional
  def get_from_grid_colors(klass, position)
    total_colors = GRID_COLORS.length
    
    if klass == :randon
      return GRID_COLORS[rand(total_colors-1)]  
    else
      return position < total_colors ? GRID_COLORS[position] : GRID_COLORS[position % total_colors]
    end
  end

end