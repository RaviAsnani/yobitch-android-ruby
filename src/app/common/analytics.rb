# Analytics - primarily GA, has provision to add more analytical trackers

java_import 'com.google.android.gms.analytics.GoogleAnalytics'
java_import 'com.google.android.gms.analytics.HitBuilders'


class Analytics
  attr_accessor :context, :property_id, :ga_tracker

  def initialize(context, property_id)
    @context = context
    @property_id = property_id
    @ga_tracker = ga_get_tracker

    ga_config_tracker
  end


  def fire_event(event_data)
    ga_fire_event(event_data)
  end


  # screen_name is a symbol to promote underscore screen names
  def fire_screen(screen_name)
    ga_fire_screen(screen_name.to_s)
  end


  def set_user(email)
    ga_set_user(email)
  end



  private

  # GA specific configurations
  def ga_config_tracker
    GoogleAnalytics::get_instance(@context).set_local_dispatch_period(15) # in seconds
  end


  # GA specific - setups up the user's profile
  def ga_set_user(email)
    @ga_tracker.set("&uid", email)
  end


  # GA specific fire event
  def ga_fire_event(event_data)
    @ga_tracker.send(HitBuilders::EventBuilder.new
                  .set_category(event_data[:category])
                  .set_action(event_data[:action])
                  .set_label(event_data[:label])
                  .build())
  end


  # GA specific fire screen
  def ga_fire_screen(screen_name)
    @ga_tracker.set_screen_name(screen_name)
    @ga_tracker.send(HitBuilders::AppViewBuilder.new.build())
  end


  # GA specific - get google analytics tracker
  def ga_get_tracker
    return GoogleAnalytics::get_instance(@context).new_tracker(@property_id)
  end

end


