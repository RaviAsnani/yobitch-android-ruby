require "app/boot"

ruboto_import_widgets :TextView, :ListView, :ArrayAdapter, :BaseAdapter


class BitchListAdapter < ArrayAdapter
  attr_accessor :message_list, :context, :view

  def initialize(context, view_id, message_list)
    super(context, view_id, message_list)
    @context = context
    @message_list = message_list
  end


  def getView(position, convert_view, parent_view_group)
    row_view = convert_view

    # Inflate the row_view if it's null. If not, just use it as it is.
    if(row_view == nil)
      Logger.d("Row view was nil")
      inflater = @context.get_system_service(Context::LAYOUT_INFLATER_SERVICE)
      row_view = inflater.inflate($package.R::layout::bitch_layout, parent_view_group, false)
    end

    Logger.d("Packing bitch TextView")
    # Find the layout's inner elements & populate them
    text_view = row_view.find_view_by_id($package.R::id::bitch)
    text_view.set_text(@message_list[position]["abuse"])

    return row_view
  end

end









