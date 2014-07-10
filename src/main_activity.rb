require 'ruboto/widget'
require 'ruboto/util/toast'

require "app/boot"
require "app/models/user"
require "app/adapters/bitch_list_adapter"
require "app/adapters/friend_grid_adapter"

java_import 'com.pixate.freestyle.PixateFreestyle'
java_import 'android.support.v4.widget.DrawerLayout'

$global_main_activity = nil

class MainActivity

  attr_accessor :drawer_layout, :abuse_selection_list, :bitch_list, :friend_grid, :user

  # Entry point into the app
  def onCreate(bundle)
    super
    $global_main_activity = self
    set_title "Yo! B*tch!"
    init_activity()
  end


  # UI building starts here
  def init_activity
    PixateFreestyle.init(self)
    setContentView($package.R.layout.main)

    @drawer_layout = find_view_by_id($package.R::id::drawer_layout)
    @abuse_selection_list = find_view_by_id($package.R::id::abuse_selection_list)
    @bitch_list = find_view_by_id($package.R::id::bitch_list)
    @friend_grid = find_view_by_id($package.R::id::friend_grid)
    

    # Initialize user
    User.new("Mayank Jain", "maku@makuchaku.in", "foo_token").save do |user_object|
      @user = user_object
      Logger.d(user_object["email"])
      render_ui(user_object)
    end
  end


  # Render major components of the UI
  def render_ui(user_object)
    #render_bitch_list(user_object["messages"])
    render_friend_grid(user_object["friends"])
  end


  # Renders the list of bitches in right panel
  def render_bitch_list(messages, friend_name = nil)
    bitch_list_adapter = BitchListAdapter.new(self, $package.R::id::bitch, messages, friend_name)
    @bitch_list.set_adapter(bitch_list_adapter)
  end
  

  # Renders the friend list in main screen
  def render_friend_grid(friends)
    friend_grid_adapter = FriendGridAdapter.new(self, $package.R::id::friend, friends)
    @friend_grid.set_adapter(friend_grid_adapter)

    @friend_grid.on_item_click_listener = proc { |parent_view, view, position, row_id| 
      Logger.d("On item click listener : #{position}, #{row_id}, #{@user["friends"][position]["name"]}")
      render_and_open_right_drawer(@user["friends"][position]["name"]) 
    }
  end


  # Opens the right drawer view - utility method
  def render_and_open_right_drawer(friend_name = nil)
    render_bitch_list(@user["messages"], friend_name)
    @drawer_layout.open_drawer(@abuse_selection_list)
  end


end

