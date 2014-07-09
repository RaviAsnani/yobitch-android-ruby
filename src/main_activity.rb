require 'ruboto/widget'
require 'ruboto/util/toast'

require "app/models/user.rb"

java_import 'com.pixate.freestyle.PixateFreestyle'
java_import 'android.support.v4.widget.DrawerLayout'


ruboto_import_widgets :Button, :LinearLayout, :TextView


class MainActivity

  attr_accessor :drawer_layout, :abuse_selection_list

  # Entry point into the app
  def onCreate(bundle)
    super
    set_title "Yo! B*tch!"
    init_activity()
  end


  def init_activity
    PixateFreestyle.init(self)
    setContentView($package.R.layout.main)

    @drawer_layout = find_view_by_id($package.R::id::drawer_layout)
    @abuse_selection_list = find_view_by_id($package.R::id::abuse_selection_list)
    
    @drawer_layout.open_drawer(@abuse_selection_list)

    # Initialize user
    User.new("Mayank Jain", "maku@makuchaku.in", "foo_token").save
  end

end



# class MainActivity
#   def onCreate(bundle)
#     super
#     set_title 'Domo arigato, Mr Ruboto!'

#     self.content_view =
#         linear_layout :orientation => :vertical do
#           @text_view = text_view :text => 'What hath Matz wrought?', :id => 42, 
#                                  :layout => {:width => :match_parent},
#                                  :gravity => :center, :text_size => 48.0
#           button :text => 'M-x butterfly', 
#                  :layout => {:width => :match_parent},
#                  :id => 43, :on_click_listener => proc { butterfly }
#         end
#   rescue Exception
#     puts "Exception creating activity: #{$!}"
#     puts $!.backtrace.join("\n")
#   end

#   private

#   def butterfly
#     @text_view.text = 'What hath Matz wrought!'
#     toast 'Flipped a bit via butterfly'
#   end

# end
