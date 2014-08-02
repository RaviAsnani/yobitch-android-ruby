require "app/boot"

# GRID_COLORS = ["#bf7580", "#e69688", "#ffba9a", "#ff8366", "#ff9d66", "#ffb666", "#ffcb65"]
# GRID_COLORS = ["#0074D9", "#39CCCC", "#3D9970", "#2ECC40", "#FF851B", "#FF4136", "#F012BE"]
# GRID_COLORS = ["#FF4873", "#E842BB", "#EA55FF", "#A642E8", "#8448FF", "#FFA163", "#E87E5A"]
# GRID_COLORS = ["#222FCC", "#666A99", "#44B5FF", "#FFBB84", "#CC3D00", "#222FCC", "#666A99"]
GRID_COLORS = ["#F16745", "#FF9E00", "#7BC8A4", "#4CC3D9", "#93648D"]
# GRID_COLORS = ["#2E0927", "#D90000", "#FF2D00", "#FF8C00", "#04756F"]


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