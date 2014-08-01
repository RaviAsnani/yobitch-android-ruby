require "app/boot"

ruboto_import_widgets :TextView, :ArrayAdapter


class BitchListAdapter < ArrayAdapter
  attr_accessor :message_list, :context, :view, :friend_name, :bitch_list_color

  def initialize(context, view_id, message_list, friend_name, bitch_list_color)
    super(context, view_id, message_list)
    @context = context
    @message_list = message_list
    @friend_name = friend_name
    @bitch_list_color = bitch_list_color
  end


  def getView(position, convert_view, parent_view_group)
    layout = convert_view

    # Inflate the layout if it's null. If not, just use it as it is.
    if(layout == nil)
      inflater = @context.get_system_service(Context::LAYOUT_INFLATER_SERVICE)
      layout = inflater.inflate($package.R::layout::bitch_layout, parent_view_group, false)
    end

    # Find the layout's inner elements & populate them
    text_view = layout.find_view_by_id($package.R::id::bitch)
    pre_text = (@friend_name == nil ? "" : "#{@friend_name}, ")
    text_view.set_text(pre_text + @message_list[position]["abuse"])
    text_view.set_background_color(Color::parse_color(@bitch_list_color))

    return layout
  end

end









