require "app/boot"

# Services are complicated and don't really make sense unless you
# show the interaction between the Service and other parts of your
# app.
# For now, just take a look at the explanation and example in
# online:
# http://developer.android.com/reference/android/app/Service.html
class OnBootLoadService

  def onCreate
    Logger.d("Service OnBootLoadService onCreate")
  end

  def onStartCommand(intent, flags, startId)
    Logger.d("Service OnBootLoadService onStartCommand")
    android.app.Service::START_STICKY
  end
end
