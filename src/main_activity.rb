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

# Keep a global instance of the user for just in case uses (like for GCM registration update)
$user = nil
$gcm = nil
$main_activity = nil


class MainActivity
  include ShareManager
  include Ui

  attr_accessor :drawer_layout, :abuse_selection_list, :bitch_list, :friend_grid, :user, :progress_dialog
  attr_accessor :invite_by_whatsapp, :gcm

  # Entry point into the app
  def onCreate(bundle)
    super

    $main_activity = self

    set_title "Yo! B*tch!"
    init_activity {
      Logger.d("UI init complete, now processing pending intent")
      process_pending_intent(get_intent()) # If we were opened by a notification, process any required actions
    }
  end


  # UI building starts here
  def init_activity(&on_init_complete_block)
    #InstallTracker.track_install_referrer_broadcast(self) # Start tracking app install referrer immediately
    PixateFreestyle.init(self)
    setContentView($package.R.layout.main)

    @progress_dialog = UiProgressDialog.new(self)

    setup_view_references()

    $user = @user = User.new(self) # Start with an invalid gcm token
    $gcm = @gcm = Gcm.new(self, CONFIG.get(:gcm_sender_id), @user)  # Start with empty user object

    ui_setup_complete = false
    # Render the user if data is available from cache
    if @user.is_valid_user?
      Logger.d("Serialized user object found, picking up from cache")
      all_that_happens_when_user_is_available(:verbose, &on_init_complete_block)
      ui_setup_complete = true
    else
      Logger.d("Serialized user object NOT found, hitting the network")
      # If not, ask the user to wait while we fetch from network
      @progress_dialog.show()
    end
    
    # Update the user anyways!
    # Re-render & setup UI all over again if this is the first time we are opening the app for a user
    # Else, just update the ui
    @user.save do |user_object|
      Logger.d("Going to do a POST on the user anyways!")
      if ui_setup_complete == false
        Logger.d("Going to run all_that_happens_when_user_is_available")
        all_that_happens_when_user_is_available(:verbose, &on_init_complete_block)
      else
        Logger.d("Just going to render_ui")
        run_on_ui_thread {
          render_ui(@user, :silent)  # Just re-render the UI
        }
      end
    end

  end


  # All initializations when the user object is available
  def all_that_happens_when_user_is_available(mode, &on_init_complete_block)
    Logger.d(@user.get("email"))
    Logger.d(@user.get("name"))
    run_on_ui_thread {
      render_ui(@user, mode)
      # Should always execute at the end of ui initialization
      on_init_complete_block.call
    }
    
    @gcm.register()  # Initialize GCM outside of the main thread

    # Setup what should happen when a notification is received      
    @user.listen_for_notification_received { |message|  
      user_notification_received(message)
    }

    # Know when to refresh the UI
    @user.listen_for_ui_refresh {
      Logger.d("Refreshing UI")
      run_on_ui_thread {
        render_friend_grid(@user.get("friends"))
      }
    }    
  end


  # Just stuff some important variables
  def setup_view_references
    @drawer_layout = find_view_by_id($package.R::id::drawer_layout)
    @abuse_selection_list = find_view_by_id($package.R::id::abuse_selection_list)
    @bitch_list = find_view_by_id($package.R::id::bitch_list)
    @friend_grid = find_view_by_id($package.R::id::friend_grid)
    @invite_by_whatsapp = find_view_by_id($package.R::id::invite_button)    
  end


  # Render major components of the UI
  def render_ui(user_object, mode)
    @progress_dialog.hide()
    UiToast.show(self, "Welcome, #{@user.get("name")}") if mode == :verbose

    # Prevent the drawer from responding to user swipes
    @drawer_layout.set_drawer_lock_mode(DrawerLayout::LOCK_MODE_LOCKED_CLOSED, Gravity::END)

    # Render firends on main screen
    render_friend_grid(@user.get("friends"))

    # Handle taps on invite buttons
    setup_button_handlers
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


  # Sends message to a friend
  def send_message_to_friend(friend_object, bitch_object)
    @progress_dialog.show("Yo! B*tching #{friend_object["name"]}...")
    @user.send_message(friend_object, bitch_object) {
      run_on_ui_thread {
        @progress_dialog.hide
        UiToast.show(self, "You b*tched #{friend_object["name"]}!")
      }
    }
  end


  # Handle tap events on invite by whatsapp and email
  def setup_button_handlers
    @invite_by_whatsapp.on_click_listener = proc { |view| 
      share_via_whatsapp(@user.get_invite_message)
    }
  end


  # UI interation when a notification is received by use model
  def user_notification_received(message)
    UiNotification.build(self, message)
  end


  # If we were opened by a notification, process any required actions
  # Executes at end of the UI initialization
  def process_pending_intent(intent)
    Logger.d("Processing pending intents from MainActivity")
    # Process any pending intent (like when a notification button is tapped)
    # Data currently comes via the set_action on intent. Key is to look for action:<sender_id>
    data = intent.get_action
    return if data.index(":").nil? # We don't want to process further if the intent has no related data

    klass = data.split(":").first
    sender_id = data.split(":").last

    if(klass == "notification_random_bitch")  # We need to send back a random bitch
      Logger.d("Found Pending intent with Klass => #{klass}")
      begin
        friend_object = @user.get_friend_by_id(sender_id.to_i)
        Logger.d(friend_object)
        possible_messages = @user.get("messages")
        bitch_object = possible_messages[rand(possible_messages.length-1)]
        Logger.d(bitch_object) 

        if not friend_object["id"].nil? and not bitch_object["id"].nil?
          Logger.d("Sending random bitch to #{friend_object["name"]} : #{bitch_object["abuse"]}")
          send_message_to_friend(friend_object, bitch_object)
        else
          Logger.d("Error in finding a friend or a bitch in process_pending_intent : F:#{friend_object["id"]}, B:#{bitch_object["id"]}")
        end
      rescue Exception
        Logger.exception(:main_activity_process_pending_intent, $!)
      end
    end

  end



  # Generic way of showing an error message in the activity
  def display_error_message(message)
    run_on_ui_thread {
      UiToast.show(self, message)
      @progress_dialog.hide
    }
  end



end








