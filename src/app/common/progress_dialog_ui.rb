java_import 'android.app.ProgressDialog'

class ProgressDialogUi

  attr_accessor :progress_dialog, :context

  def initialize(context)
    @context = context
    @progress_dialog = ProgressDialog.new(context)
    @progress_dialog.set_message("Please wait...")
    @progress_dialog.set_cancelable(false)
    @progress_dialog.set_indeterminate(true)    
  end


  def show
    @progress_dialog.show
  end


  def hide
    @progress_dialog.dismiss
  end

end