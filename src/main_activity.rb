require 'ruboto/widget'
require 'ruboto/util/toast'

require "app/boot"
require "app/models/user"
require "app/models/message"
require "app/adapters/bitch_list_adapter"
require "app/adapters/friend_grid_adapter"

java_import 'com.pixate.freestyle.PixateFreestyle'
java_import 'android.support.v4.widget.DrawerLayout'
java_import 'android.view.Gravity'

$global_main_activity = nil

class MainActivity

  attr_accessor :drawer_layout, :abuse_selection_list, :bitch_list, :friend_grid, :user, :progress_dialog

  # Entry point into the app
  def onCreate(bundle)
    super
    $global_main_activity = self
    set_title "Yo! B*tch!"
    init_activity()

    Logger.d DeviceAccount.new(self).get_user_details.to_s
  end


  # UI building starts here
  def init_activity
    PixateFreestyle.init(self)
    setContentView($package.R.layout.main)

    @progress_dialog = ProgressDialogUi.new(self)

    @drawer_layout = find_view_by_id($package.R::id::drawer_layout)
    @abuse_selection_list = find_view_by_id($package.R::id::abuse_selection_list)
    @bitch_list = find_view_by_id($package.R::id::bitch_list)
    @friend_grid = find_view_by_id($package.R::id::friend_grid)

    # Initialize user
    @user = User.new("Mayank Jain", "maku@makuchaku.in", "foo_token")
    @user.save do |user_object|
      #@user = user_object
      Logger.d(@user.get("email"))
      render_ui(@user)
    end
  end


  # Render major components of the UI
  def render_ui(user_object)
    # Prevent the drawer from responding to user swipes
    @drawer_layout.set_drawer_lock_mode(DrawerLayout::LOCK_MODE_LOCKED_CLOSED, Gravity::END)

    # Render firends on main screen
    render_friend_grid(@user.get("friends"))
  end
  

  # Renders the friend list in main screen
  def render_friend_grid(friends)
    friend_grid_adapter = FriendGridAdapter.new(self, $package.R::id::friend, friends)
    @friend_grid.set_adapter(friend_grid_adapter)

    @friend_grid.on_item_click_listener = proc { |parent_view, view, position, row_id| 
      Logger.d("On item click listener : #{position}, #{row_id}, #{@user.get("friends")[position]["name"]}")
      render_and_open_right_drawer(@user.get("friends")[position]) 
    }
  end


  # Opens the right drawer view with a given target user's name
  def render_and_open_right_drawer(friend_object)
    # Render the bitch list based on which user is tapped from main screen
    render_bitch_list(@user.get("messages"), friend_object)
    @drawer_layout.open_drawer(@abuse_selection_list)
  end


  # Renders the list of bitches in right panel
  def render_bitch_list(messages, friend_object)
    bitch_list_adapter = BitchListAdapter.new(self, $package.R::id::bitch, messages, friend_object["name"])
    @bitch_list.set_adapter(bitch_list_adapter)

    @bitch_list.on_item_click_listener = proc { |parent_view, view, position, row_id| 
      @progress_dialog.show
      Logger.d("On item click listener : #{position}, #{row_id}, #{@user.get("messages")[position]["abuse"]}")
      close_right_drawer
      # Send the bitch!
      send_message_to_friend(friend_object, @user.get("messages")[position])
    }
  end


  # Closes the drawer
  def close_right_drawer
    @drawer_layout.close_drawer(@abuse_selection_list)
  end


  def send_message_to_friend(friend_object, bitch_object)
    Message.new(@user, friend_object, bitch_object)
      .send do
        @progress_dialog.hide
      end
  end

end

