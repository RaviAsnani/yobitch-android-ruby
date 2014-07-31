require "app/boot"

module DisplayUtils

  # Sleep for delay seconds and then render on UI thread
  def run_on_ui_thread_with_delay(delay, &block)
    Thread.start do
      sleep(delay)
      run_on_ui_thread {
        block.call
      }
    end # Thread ends
  end

end