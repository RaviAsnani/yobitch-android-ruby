require "app/boot"
java_import 'android.graphics.Color'

ruboto_import_widgets :TextView, :ArrayAdapter

class FriendGridAdapter < ArrayAdapter
  attr_accessor :friend_list, :context, :view

  def initialize(context, view_id, friend_list)
    super(context, view_id, friend_list)
    @context = context
    @friend_list = friend_list
  end


  def getView(position, convert_view, parent_view_group)
    layout = convert_view
    colors = ["#693f69", "#7c4866", "#bf7580", "#e69688", "#ffba9a", "#ff8366", "#ff9d66", "#ffb666", "#ffcb65", "#ffdb65"]


    # Inflate the layout if it's null. If not, just use it as it is.
    if(layout == nil)
      inflater = @context.get_system_service(Context::LAYOUT_INFLATER_SERVICE)
      layout = inflater.inflate($package.R::layout::friend_layout, parent_view_group, false)
    end

    # Find the layout's inner elements & populate them
    text_view = layout.find_view_by_id($package.R::id::friend_item)
    text_view.set_text(@friend_list[position]["name"])
    random_color = colors[rand(colors.length-1)]
    text_view.set_background_color(Color::parse_color(random_color))
    
    return layout
  end

end









