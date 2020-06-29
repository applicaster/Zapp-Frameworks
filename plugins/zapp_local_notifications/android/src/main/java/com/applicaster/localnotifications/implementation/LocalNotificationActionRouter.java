package com.applicaster.localnotifications.implementation;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * This entire class is needed to dismiss notification on action button click
 */
public class LocalNotificationActionRouter extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        int notificationId = intent.getIntExtra(NotificationBuilder.NOTIFICATION_ID_EXTRA, 0);
        if(0 != notificationId) {
            // hack to dismiss notification when action button is clicked
            NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            manager.cancel(notificationId);
            // Close the notifications drawer
            context.sendBroadcast(new Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS));
        }
        Intent routedIntent = intent.getParcelableExtra(NotificationBuilder.WRAPPED_INTENT_EXTRA);
        if(null == routedIntent) {
            throw new RuntimeException("Application missing launch intent");
        }
        context.startActivity(routedIntent);
    }
}
