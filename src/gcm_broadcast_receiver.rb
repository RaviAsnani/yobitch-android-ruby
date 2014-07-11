import android.util.Log
import android.support.v4.content.WakefulBroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.app.Activity

class GcmBroadcastReceiver
  # Will get called whenever the BroadcastReceiver receives an intent.
  def onReceive(context, intent)
    Log.v 'GcmBroadcastReceiver', 'Broadcast received!'
    Log.v 'GcmBroadcastReceiver', intent.get_extras.get_string("registration_id")
  rescue Exception
    Log.e 'GcmBroadcastReceiver', "Exception processing broadcast: #{$!.message}\n#{$!.backtrace.join("\n")}"
  end
end



# import android.util.Log;
# import android.support.v4.content.WakefulBroadcastReceiver;
# import android.content.Context;
# import android.content.Intent;
# import android.content.ComponentName;
# import android.app.Activity;


# public class GcmBroadcastReceiver extends WakefulBroadcastReceiver {
#     @Override
#     public void onReceive(Context context, Intent intent) {
#       Log.i("GcmBroadcastReceiver", "onReceive started =================================");
#       String regId = intent.getExtras().getString("registration_id");
#       Log.i("GcmBroadcastReceiver", "RegId : " + regId + " =================================");
#       // Explicitly specify that GcmIntentService will handle the intent.
#       ComponentName comp = new ComponentName(context.getPackageName(),
#               GcmIntentService.class.getName());
#       // Start the service, keeping the device awake while it is launching.
#       startWakefulService(context, (intent.setComponent(comp)));
#       setResultCode(Activity.RESULT_OK);
#     }
# }