require 'ruboto/widget'
require 'ruboto/util/toast'

require "app/boot"
require "app/models/user"
require "app/adapters/bitch_list_adapter"
require "app/adapters/friend_grid_adapter"

java_import 'com.pixate.freestyle.PixateFreestyle'
java_import 'android.support.v4.widget.DrawerLayout'


class MainActivity

  attr_accessor :drawer_layout, :abuse_selection_list, :bitch_list, :friend_grid

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
    @bitch_list = find_view_by_id($package.R::id::bitch_list)
    @friend_grid = find_view_by_id($package.R::id::friend_grid)
    
    @drawer_layout.open_drawer(@abuse_selection_list)

    # Initialize user
    User.new("Mayank Jain", "maku@makuchaku.in", "foo_token").save do |user_object|
      Logger.d(user_object["email"])

      #TODO - Refactor out to its own method
      bitch_list_adapter = BitchListAdapter.new(self, $package.R::id::bitch, user_object["messages"])
      @bitch_list.set_adapter(bitch_list_adapter)

      #TODO - Refactor out to its own method
      friend_grid_adapter = FriendGridAdapter.new(self, $package.R::id::friend, user_object["friends"])
      @friend_grid.set_adapter(friend_grid_adapter)      
    end
  end

end

