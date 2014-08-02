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
java_import 'com.bugsense.trace.BugSenseHandler'
java_import 'android.content.Intent'
java_import 'android.net.Uri'

java_import 'com.appnext.appnextsdk.Appnext'


# Keep a global instance of the user for just in case uses (like for GCM registration update)
$user = nil
$gcm = nil
$main_activity = nil


class MainActivity
  include DisplayUtils
  include ShareManager
  include Ui
  include Ads

  attr_accessor :drawer_layout, :abuse_selection_list, :bitch_list, :friend_grid, :user, :progress_dialog
  attr_accessor :invite_by_whatsapp, :gcm, :analytics, :message_add_button, :appnext_ads

  # Entry point into the app
  def onCreate(bundle)
    super
    track_app_state("onCreate")
    set_title "Yo! B*tch!"

    @progress_dialog = UiProgressDialog.new(self) 
    @progress_dialog.show

    # Render a super fast startup - push all processing off the main thread for 1 sec
    run_on_ui_thread_with_delay(1) {
      $main_activity = self # Save reference to the main activity
      $user = @user = User.new(self) # Start with an invalid gcm token
      $gcm = @gcm = Gcm.new(self, CONFIG.get(:gcm_sender_id), @user)  # Start with empty user object    

      process_opening_intent(get_intent())  # Process the intent which did this invocation

      init_activity {
        Logger.d("UI init complete, now processing pending intent")
        process_pending_intent(get_intent()) # If we were opened by a notification, process any required actions
      }
    }
  end


  def onStart
    super
    track_app_state("onStart")
  end

  def onRestart
    super
    track_app_state("onRestart")
  end

  def onResume
    super
    track_app_state("onResume")
  end

  def onPause
    super
    track_app_state("onPause")
  end

  def onStop
    super
    track_app_state("onStop")
  end

  def onDestroy
    super
    track_app_state("onDestroy")
  end

  # Try to close the ad popup if its open. Otherwise close the app
  # BUG - popup is closed from (x) and then back is presses, it'll first try to close the ad which will fail. It'll only second time close the app
  def onBackPressed
    track_app_state("onBackPressed")
    if not @appnext_ads.nil?
      @appnext_ads.hide_bubble 
      @appnext_ads = nil
    else
      super
    end
  end


  # UI building starts here
  def init_activity(&on_init_complete_block)
    BugSenseHandler.initAndStartSession(self, CONFIG.get(:bugsense_id)) # Initiate crash tracking
    @analytics = Analytics.new(self, CONFIG.get(:ga_tracking_id)) # Initiate Analytics
    PixateFreestyle.init(self)  # Initiate Freestyle

    setContentView($package.R.layout.main)

    setup_view_references()

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
        render_ui  # Just re-render the UI
      end
    end

    # Load ads
    run_on_ui_thread_with_delay(1) {
      get_admob_ad_view(self, 
          find_view_by_id($package.R::id::id_main_screen_layout),
          CONFIG.get(:admob_ad_unit_id))
    }
  end


  # All initializations when the user object is available
  # mode => :verbose, :silent
  # Don't call this method when UI refresh is needed. Instead refer to render_ui method
  def all_that_happens_when_user_is_available(mode, &on_init_complete_block)
    Logger.d(@user.get("email"))
    Logger.d(@user.get("name"))
    
    BugSenseHandler.set_user_identifier(@user.get("email")) # Tell BugSense who is this user
    @analytics.set_user(@user.get("email"))

    message = mode == :verbose ? "Welcome, #{@user.get("name")}" : nil
    render_ui(message)
      
    run_on_ui_thread {
      # Should always execute at the end of ui initialization 
      on_init_complete_block.call
    }
    
    @gcm.register()  # Initialize GCM outside of the main thread

    # Know when to refresh the UI
    @user.listen_for_ui_refresh {
      Logger.d("Refreshing UI")
      render_ui
    }    

    # Show Appnext interstitial ad upon entry
    run_on_ui_thread_with_delay(0) {
      @appnext_ads = get_appnext_interstitial_ad(self, CONFIG.get(:appnext_ad_placement_id))
    }
  end



  # Just stuff some important variables
  # find_view_by_id is VERY expensive. Only spend time in finding those view references which are needed on app startup
  # Nothing else should be used with find_view_by_id
  def setup_view_references
    @drawer_layout = find_view_by_id($package.R::id::drawer_layout)
    @friend_grid = find_view_by_id($package.R::id::friend_grid)
    @invite_by_whatsapp = find_view_by_id($package.R::id::invite_button)
    @message_add_button = @drawer_layout.find_view_by_id(Ruboto::R::id::id_message_add_button)
  end



  # Render major components of the UI
  # Always refer to this method to refresh the UI in entirety
  # Toast message will only be shown when the mode==:verbose
  # Expensive - runs on the UI thread
  def render_ui(toast_message=nil)
    run_on_ui_thread {
      # Prevent the drawer from responding to user swipes
      @drawer_layout.set_drawer_lock_mode(DrawerLayout::LOCK_MODE_LOCKED_CLOSED, Gravity::END)

      # Render firends on main screen
      run_on_ui_thread_with_delay(0) {
        render_friend_grid(@user.get_friends)

        @progress_dialog.hide()
        UiToast.show(self, toast_message) if toast_message != nil      
      }

      # Handle taps on invite buttons & add message buttons
      setup_button_handlers

      @analytics.fire_screen(:home_screen)
    }
  end

  

  # Renders the friend list in main screen
  def render_friend_grid(friends)
    friend_grid_adapter = FriendGridAdapter.new(self, $package.R::id::friend_item, friends)
    @friend_grid.set_adapter(friend_grid_adapter)

    @friend_grid.on_item_click_listener = proc { |parent_view, view, position, row_id| 
      Logger.d("On item click listener : #{position}, #{row_id}, #{@user.get_friends[position]["name"]}")

      @analytics.fire_event({:category => "home_screen", :action => "tap", :label => "friend"})
      @analytics.fire_event({:category => "home_screen", :action => "stats_friend_tap", :label => "friend : #{@user.get_friends[position]["name"]}"})
      
      render_and_open_right_drawer(@user.get_friends[position], position) 
    }
  end



  # Opens the right drawer view with a given target user's name
  def render_and_open_right_drawer(friend_object, position)
    # Render the bitch list based on which user is tapped from main screen
    render_bitch_list(@user.get("messages"), friend_object, get_from_grid_colors(:positional, position))
    @abuse_selection_list = find_view_by_id($package.R::id::abuse_selection_list)
    @drawer_layout.open_drawer(@abuse_selection_list)
    @analytics.fire_screen(:bitch_drawer)
  end



  # Renders the list of bitches in right panel
  def render_bitch_list(messages, friend_object, bitch_list_color)
    bitch_list_adapter = BitchListAdapter.new(self, 
                                $package.R::id::bitch, messages, 
                                friend_object["name"],
                                bitch_list_color)

    @bitch_list = find_view_by_id($package.R::id::bitch_list)
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
    @analytics.fire_event({:category => "bitch_drawer", :action => "tap", :label => "bitch"})
    @analytics.fire_event({:category => "bitch_drawer", :action => "stats_bitch_tap", :label => "bitch : #{bitch_object["abuse"]}"})
   
    Logger.d("Yo! B*tching #{friend_object["name"]} with : #{bitch_object["abuse"]}")
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
      @analytics.fire_event({:category => "home_screen", :action => "tap", :label => "share : whatsapp"})
      share_via_whatsapp(@user.get_invite_message)
    }

    @message_add_button.on_click_listener = proc { |view| 
      on_message_add_button_clicked
    }
  end



  # When the add bitch message button is clicked
  def on_message_add_button_clicked
    Logger.d("message_add_button tapped!!")
    UiDialogWithInput.show(self, 
                            {
                              :title => "Create a new B*tch message", 
                              :message => "Enter the new message",
                              :positive_button => "Save", 
                              :negative_button => "Cancel" 
                            },
                            Proc.new { |new_bitch_message| 
                              Logger.d("User added new bitch message : #{new_bitch_message}")
                              run_on_ui_thread {@progress_dialog.show()}
                              @user.add_bitch_message(new_bitch_message) {
                                render_ui("Message added to the list")
                              }
                            }
                          )
  end




  # UI interation when a notification is received
  def self.on_notification_received(context, message)
    analytics = Analytics.new(context, CONFIG.get(:ga_tracking_id)) # Initiate Analytics

    notification_data = JSON.parse(message)
    analytics.fire_event({:category => "notification", :action => "received", 
                          :label => notification_data["klass"]})
   
    UiNotification.build(context, notification_data)
  end



  # Extract any info out of the intent which triggered this invocation
  # Specially to be used for live handling of friend addition
  def process_opening_intent(intent)
    Logger.d("#{get_intent().get_data()}", "?")
    tapped_url = intent.get_data()

    begin
      if tapped_url != nil
        friend_id = tapped_url.to_s.split("/")[4].to_i
        Logger.d("Add friend : #{friend_id}", "?")
        @user.add_future_friend(friend_id)
      end
    rescue
      Logger.exception(:process_opening_intent, $!)
    end
  end



  # If we were opened by a notification, process any required actions
  # Executes at end of the UI initialization
  def process_pending_intent(intent)
    UiNotification.cancel_all(self) # cancel all open notifications

    Logger.d("Processing pending intents from MainActivity")
    # Process any pending intent (like when a notification button is tapped)
    # Data currently comes via the set_action on intent. Key is to look for action:<sender_id>
    data = intent.get_action
    return if data.index(":").nil? # We don't want to process further if the intent has no related data

    klass = data.split(":").first
    sender_id = data.split(":").last

    if(klass == "notification_random_bitch")  # We need to send back a random bitch
      Logger.d("Found Pending intent with Klass => #{klass}")
      @analytics.fire_event({:category => "notification", :action => "replied", :label => "random_bitch"})
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


  # Util method to track various states of this activity
  def track_app_state(state_name)
    Logger.d("In #{state_name}")
    analytics = Analytics.new(self, CONFIG.get(:ga_tracking_id))
    analytics.fire_event({:category => "android", :action => "app_state", :label => state_name})
  end


  # Create options menu
  def onCreateOptionsMenu(menu)
    inflater = get_menu_inflater()
    inflater.inflate($package.R::layout::options_menu, menu)
    return true
  end


  # Handle options menu
  def onOptionsItemSelected(menu_item)
    Logger.d("Menu option tapped : #{menu_item.get_item_id}")

    case menu_item.get_item_id()
    when $package.R::id::options_menu_add_message
      on_message_add_button_clicked
    when $package.R::id::options_menu_rate
      intent = Intent.new(Intent::ACTION_VIEW)
      intent.set_data(Uri.parse("market://details?id=#{CONFIG.get(:package_name)}"))
      start_activity(intent)
    end
      
    return true
  end

end








