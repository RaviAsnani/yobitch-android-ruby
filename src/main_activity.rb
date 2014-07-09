require 'ruboto/widget'
require 'ruboto/util/toast'

require "app/boot"
require "app/models/user"

java_import 'com.pixate.freestyle.PixateFreestyle'
java_import 'android.support.v4.widget.DrawerLayout'


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
    User.new("Mayank Jain", "maku@makuchaku.in", "foo_token").save do |user_object|
      Logger.d(user_object["email"])
    end
  end

end

