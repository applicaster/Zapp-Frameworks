package com.applicaster.localnotifications.implementation;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.Nullable;
import androidx.core.app.AlarmManagerCompat;

import com.applicaster.app.APProperties;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppData;
import com.applicaster.util.OSUtil;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import org.jetbrains.annotations.NotNull;

import java.util.List;

public class LocalNotificationBroadcastReceiver extends BroadcastReceiver {

    private static final String PAYLOAD_JSON_KEY = "payload";
    private static final String TAG = "LocalNotificationBroadcastReceiver";

    /**
     * schedules broadcast Intent with LocalNotificationPayload to be delivered and handled at triggerAtMillis
     * @param context context
     * @param identifier unique string identified for scheduled intent
     * @param triggerAtMillis when to trigger,
     * @param payloadJson LocalNotificationPayload as JSON string
     */
    public static void scheduleNotification(@NotNull Context context,
                                            @NotNull String identifier,
                                            long triggerAtMillis,
                                            @NotNull String payloadJson) {
        PendingIntent pendingIntent = makePendingIntent(context, identifier, payloadJson);
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        AlarmManagerCompat.setExactAndAllowWhileIdle(am, AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent);
        APLogger.debug(TAG, "Notification was scheduled: " + identifier);
    }

    /**
     * Creates new or returns existing scheduled pending intent
     * @param context
     * @param identifier unique string identified for scheduled intent
     * @param payloadJson LocalNotificationPayload as JSON string
     * @return New intent if payloadJson was provided,
     * otherwise existing intent with identifier specified.
     */
    private static PendingIntent makePendingIntent(@NotNull Context context,
                                                   @NotNull String identifier,
                                                   @Nullable String payloadJson) {
        Intent intent = new Intent(context, LocalNotificationBroadcastReceiver.class);
        intent.addCategory(OSUtil.getPackageName());
        if(null != payloadJson) {
            intent.putExtra(PAYLOAD_JSON_KEY, payloadJson);
        }

        // Identity part, so notification could be found later via identifier
        // not used for anything else yet
        ComponentName componentName = new ComponentName(context, LocalNotificationBroadcastReceiver.class);
        String component = componentName.flattenToString();
        String scheme = AppData.getProperty(APProperties.URL_SCHEME_PREFIX);
        Uri uri = new Uri.Builder()
                .scheme(scheme)
                .appendEncodedPath(component)
                .appendQueryParameter("identifier", identifier)
                .build();
        intent.setData(uri);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            intent.setIdentifier(identifier);
        }
        // not really needed, setIdentifier and setData is enough to find it
        int alarmId = identifier.hashCode();

        return PendingIntent.getBroadcast(context,
                alarmId, intent,
                null != payloadJson ? PendingIntent.FLAG_UPDATE_CURRENT : PendingIntent.FLAG_NO_CREATE);
    }

    public static void cancelLocalNotifications(@NotNull Context context,
                                                @NotNull List<String> identifiers) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        for (String identifier : identifiers) {
            PendingIntent pi = makePendingIntent(context, identifier, null);
            if(null != pi) {
                am.cancel(pi);
                pi.cancel();
                APLogger.debug(TAG, "Scheduled notification was cancelled: " + identifier);
            } else{
                APLogger.warn(TAG, "Failed to cancel scheduled notification, not found " + identifier);
            }
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String payload = intent.getStringExtra(PAYLOAD_JSON_KEY);
        if(null == payload) {
            APLogger.error(TAG, "Missing payload data in received intent");
            return;
        }
        try {
            LocalNotificationPayload notification = new Gson().fromJson(payload, LocalNotificationPayload.class);
            new NotificationBuilder(context).presentNotification(notification);
        } catch(JsonSyntaxException ex){
            APLogger.error(TAG, "Failed to decode payload data in received intent: " + payload, ex);
        } catch(Exception ex){
            APLogger.error(TAG, "Failed to present scheduled notification: " + payload, ex);
        }
    }
}
