require "app/boot"

ruboto_import_widgets :TextView, :ListView, :ArrayAdapter, :BaseAdapter


class BitchListAdapter < ArrayAdapter
  attr_accessor :message_list, :context, :view

  def initialize(context, view_id, message_list)
    super(context, view_id, message_list)
    Logger.d "0============================================================="
    @context = context
    #@view = find_view_by_id(view)
    @message_list = message_list
  end


  def getView(position, convert_view, parent_view_group)
    Logger.d "1============================================================="
    if convert_view == nil
      Logger.d "nil============================================================="
      convert_view = TextView.new(@context)
      convert_view.set_text("Foo")
    else
      Logger.d "not.nil============================================================="
      Logger.d(@message_list.to_s)
      convert_view.set_text(@message_list[position]["abuse"])
    end
    Logger.d "2============================================================="
    return convert_view 
  end

end

# class BitchListAdapter < BaseAdapter

#   attr_accessor :message_list, :context

#   def initialize(context, message_list)
#     super()
#     Logger.d "0============================================================="
#     @context = context
#     @message_list = message_list
#     @message_list = ArrayList.new
#   end

#   def getCount(arg)
#     Logger.d("LOG01")
#     return @message_list.length
#   end

#   def getItem(arg)
#     Logger.d("LOG02")
#     return message_list[arg] if arg < message_list.length
#     raise "BitchListAdapter:get_item index out of bounds"
#   end

#   def getItemId(arg)
#     Logger.d("LOG03")
#     return arg
#   end

#   def hasStableIds
#     Logger.d("LOG04")
#     return true
#   end

#   def isEmpty
#     Logger.d("LOG05")
#     return @message_list.length == 0
#   end


#   #TODO : As a possible example, see https://github.com/ruboto/ruboto/blob/afbe6377a8ab96a9bedc3fbed1f33f1c912ed557/test/activity/subclass_activity.rb
#   def getView(position, convert_view, parent_view_group)
#     Logger.d("LOG06")
#     Logger.d "1============================================================="
#     inflater = @context.get_system_service(Context::LAYOUT_INFLATER_SERVICE)

#     #View rowView = inflater.inflate(R.layout.bitch_layout, parent, false);
#     #TextView textView1 = (TextView) rowView.findViewById(R.id.abuse);    

#     row_view = inflater.inflate($package.R::layout::bitch_layout, parent, false)
#     text_view = row_view.find_view_by_id($package.R::id::abuse)

#     text_view.set_text(@message_list[position]["abuse"])
#     Logger.d "2============================================================="

#     return row_view
#   end



# end










