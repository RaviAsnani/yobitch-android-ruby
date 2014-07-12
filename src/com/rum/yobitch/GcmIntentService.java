package com.rum.yobitch;

import android.util.Log;
import android.os.Bundle;
import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import com.google.android.gms.gcm.GoogleCloudMessaging;


public class GcmIntentService extends IntentService {
    public static final int NOTIFICATION_ID = 1;
    //private NotificationManager mNotificationManager;
    //NotificationCompat.Builder builder;

    public GcmIntentService() {
        super("GcmIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Log.i("RUBOTO GcmIntentService", "onHandleIntent started =================================");
        Bundle extras = intent.getExtras();
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        // The getMessageType() intent parameter must be the intent you received
        // in your BroadcastReceiver.
        String messageType = gcm.getMessageType(intent);

        if (!extras.isEmpty()) {  // has effect of unparcelling Bundle
            if (GoogleCloudMessaging.
                    MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
                sendNotification("Send error: " + extras.toString());
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_DELETED.equals(messageType)) {
                sendNotification("Deleted messages on server: " +
                        extras.toString());
            // If it's a regular GCM message, do some work.
            } else if (GoogleCloudMessaging.
                    MESSAGE_TYPE_MESSAGE.equals(messageType)) {
                sendNotification("Received: " + extras.toString());
                Log.i("GcmIntentService", "Received: " + extras.toString());
            }
        }
        // Release the wake lock provided by the WakefulBroadcastReceiver.
        //GcmBroadcastReceiver.completeWakefulIntent(intent);
    }



    // Put the message into a notification and post it.
    // This is just one simple example of what you might choose to do with
    // a GCM message.
    private void sendNotification(String msg) {
        Log.i("GcmIntentService", "Received: " + msg);
        // mNotificationManager = (NotificationManager)
        //         this.getSystemService(Context.NOTIFICATION_SERVICE);

        // PendingIntent contentIntent = PendingIntent.getActivity(this, 0,
        //         new Intent(this, DemoActivity.class), 0);

        // NotificationCompat.Builder mBuilder =
        //         new NotificationCompat.Builder(this)
        // .setSmallIcon(R.drawable.ic_stat_gcm)
        // .setContentTitle("GCM Notification")
        // .setStyle(new NotificationCompat.BigTextStyle()
        // .bigText(msg))
        // .setContentText(msg);

        // mBuilder.setContentIntent(contentIntent);
        // mNotificationManager.notify(NOTIFICATION_ID, mBuilder.build());
    }
}