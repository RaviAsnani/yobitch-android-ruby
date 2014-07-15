Open Todo's
* Handle case when there are no friends of a user => Is it even valid anymore with the Bot in place?
* Write a boot service which loads the jruby instance  (Incomplete work in boot_completed branch. Crash when notification is received)
* Handle errors in network calls
* Beautify UI - make it look like actual Yo!
* Add a splash screen while jruby loads
* Add an actionbar with a possible refresh button (which just re-inits the ui)



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



Best if's
* Usage of friend should be moved to a separate Friend model (which does not exists yet)
* MessageList and FriendList models should be introduced
* Data exchange from notification received to activity opened via intent is very hacky as of now. Explore better options via either a Bundle or Intent.put_extra mechanism



Delayed till next versions
* Invite by email
* Contacts sync


