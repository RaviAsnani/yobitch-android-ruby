Open Todo's
* Write a boot service which loads the jruby instance  (Incomplete work in boot_completed branch. Crash when notification is received)
* Explore using https://github.com/nathankleyn/ruby_events for events
* Logcat STILL complains too much is happening on main thread.
* Add ability to add your own bitch message but make it paid
* When notification is tapped, another instance of app is created (which can be verified by pressing back button)
* Sync all contacts and use that as means to determine that who all should receive a push when someone comes online. This should NOT happen everytime
* When install referrer is fired and if at that time the app is not open, system keeps on looping into a threaded $user.wait_till_user_is_inflated method. Thought, things work out fine when app starts. Maybe sleep longer at this stage? OR pull out (& update) the user from shared preferences?
* When A invites B and A's app is in onStop state, the friend_add push crashes in gcm_broadcast_receiver.rb:16:$gcm.on_gcm_message_received(data) => Somehow the contexts of $user and $gcm need to be restored from anywhere.
* App should not crash when started with no internet connection. It should error out gracefully.



Closed Todo's
* Setup Toast to display user’s name when he logs in - refactor into common/ui
* Setup toast when user sends a bitch
* Better config management - dev/production
* GCM registration
* Loader is not working/showing
* Whatsapp share
* Logcat complains too much is happening on main thread. Either explore AsyncTask or understand the usage of Thread.join
* Tapping on push notification - nothing happens
* Push notification UI is invoked from User model - that sucks. Can we somehow route it back to MainActivity?
* Handle install referer
* Send back a random bitch when the related action is tapped from notification
* Package JRuby core with the apk
* Handle errors in network calls
* Handle case when there are no friends of a user => Is it even valid anymore with the Bot in place?
* Save user locally on device
* Add a splash screen while jruby loads
* Play sound when a push arrives
* Add ads
* Add BugSense
* Add Analytics
* Notification does not goes away when user decides to send a random bitch
* Beautify UI
* Sender should be notified by a push that his invitee has joined - server side & client side work. Opening of that push should enforce an app refresh




Best if's
* Usage of friend should be moved to a separate Friend model (which does not exists yet)
* MessageList and FriendList models should be introduced
* Data exchange from notification received to activity opened via intent is very hacky as of now. Explore better options via either a Bundle or Intent.put_extra mechanism



Delayed till next versions
* Invite by email


