require "app/boot"
java_import 'android.graphics.Color'

ruboto_import_widgets :TextView, :ArrayAdapter

class FriendGridAdapter < ArrayAdapter
  attr_accessor :friend_list, :context

  def initialize(context, view_id, friend_list)
    super(context, view_id, friend_list)
    @context = context
    @friend_list = friend_list
  end


  def getView(position, convert_view, parent_view_group)
    layout = convert_view
    colors = ["#bf7580", "#e69688", "#ffba9a", "#ff8366", "#ff9d66", "#ffb666", "#ffcb65"]

    # Inflate the layout if it's null. If not, just use it as it is.
    if(layout == nil)
      inflater = @context.get_system_service(Context::LAYOUT_INFLATER_SERVICE)
      layout = inflater.inflate($package.R::layout::friend_layout, parent_view_group, false)
    end

    # Find the layout's inner elements & populate them
    text_view = layout.find_view_by_id($package.R::id::friend_item)
    image_view = layout.find_view_by_id($package.R::id::friend_item_klass)
    
    text_view.set_text(@friend_list[position]["name"])

    icon = @friend_list[position]["klass"] == :starred_contact ? Ruboto::R::drawable::sms_small : Ruboto::R::drawable::shout_small
    image_view.set_image_resource(icon)

    layout.set_background_color(Color::parse_color(get_color(colors, position)))
    
    return layout
  end


  def get_color(colors, position)
    total_colors = colors.length
    return position < total_colors ? colors[position] : colors[position % total_colors]
  end

end









