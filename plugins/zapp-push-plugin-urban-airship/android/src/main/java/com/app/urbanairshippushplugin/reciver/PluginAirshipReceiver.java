package com.app.urbanairshippushplugin.reciver;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.util.StringUtil;
import com.applicaster.util.push.PushUtil;
import com.urbanairship.actions.DeepLinkListener;
import com.urbanairship.channel.AirshipChannelListener;
import com.urbanairship.push.NotificationActionButtonInfo;
import com.urbanairship.push.NotificationInfo;
import com.urbanairship.push.NotificationListener;
import com.urbanairship.push.PushListener;
import com.urbanairship.push.PushMessage;

/**
 * Created by user on 11/29/16.
 */
public class PluginAirshipReceiver implements PushListener, NotificationListener, AirshipChannelListener {

    private static final String TAG = "PluginAirshipReceiver";
    private final Context mContext;
    private final DeepLinkListener mDeepLinkListener = new DeepLinkListener() {
        @Override
        public boolean onDeepLink(@NonNull String s) {
            Log.i(TAG, "Handling DeepLink: " + s);
            launchActivity(mContext.getApplicationContext(), Uri.parse(s));
            return true;
        }
    };

    public PluginAirshipReceiver(Context context) {
        mContext = context;
    }

    @Override
    public void onChannelCreated(@NonNull String channelId) {
        Log.i(TAG, "Channel created. Channel Id:" + channelId + ".");
    }

    @Override
    public void onChannelUpdated(@NonNull String channelId) {
        Log.i(TAG, "Channel updated. Channel Id:" + channelId + ".");
    }

    @Override
    public void onPushReceived(@NonNull PushMessage message, boolean notificationPosted) {
        Log.i(TAG, "Received push message. Alert: " + message.getAlert() + ". posted notification: " + notificationPosted);
    }

    @Override
    public void onNotificationPosted(@NonNull NotificationInfo notificationInfo) {
        Log.i(TAG, "Notification posted. Alert: " + notificationInfo.getMessage().getAlert() + ". NotificationId: " + notificationInfo.getNotificationId());
    }

    @Override
    public boolean onNotificationOpened(@NonNull NotificationInfo notificationInfo) {
        Log.i(TAG, "Notification opened. Alert: " + notificationInfo.getMessage().getAlert() + ". NotificationId: " + notificationInfo.getNotificationId());
        PushMessage message = notificationInfo.getMessage();
        onTapAnalyticsEvent(message);
        return false;
    }

    @Override
    public boolean onNotificationForegroundAction(@NonNull NotificationInfo notificationInfo, @NonNull NotificationActionButtonInfo notificationActionButtonInfo) {
        String buttonId = notificationActionButtonInfo.getButtonId();
        Log.i(TAG, "Notification action button opened. Button ID: " + buttonId + ". NotificationId: " + notificationInfo.getNotificationId());
        PushMessage message = notificationInfo.getMessage();
        onTapAnalyticsEvent(message);
        return false;
    }

    @Override
    public void onNotificationBackgroundAction(@NonNull NotificationInfo notificationInfo, @NonNull NotificationActionButtonInfo notificationActionButtonInfo) {
        PushMessage message = notificationInfo.getMessage();
        onTapAnalyticsEvent(message);
    }

    private void launchActivity(@NonNull Context context, @Nullable Uri uri) {
        Intent notificationIntent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
        if(null == notificationIntent){
            // should not happen in our applications
            notificationIntent = new Intent();
            notificationIntent.setClassName(context, "com.applicaster.componentsapp.IntroActivity");
        }
        if(uri != null) {
            notificationIntent.setData(uri);
        }
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        context.startActivity(notificationIntent);
    }

    private void onTapAnalyticsEvent(PushMessage message){
        String title = message.getAlert();
        String mesg = message.getTitle();
        String messageId = message.getCanonicalPushId();
        String description = message.getSummary();
        String provider = "Urban Airship";
        Intent intent = new Intent();
        PushUtil.updateAnalyticsParams(intent, messageId, StringUtil.isNotEmpty(title), null, provider, mesg, description, title);
        PushUtil.sendNotificationAnalyticsParams(intent);
    }

    @Override
    public void onNotificationDismissed(@NonNull NotificationInfo notificationInfo) {
        Log.i(TAG, "Notification dismissed. Alert: " + notificationInfo.getMessage().getAlert() + ". Notification ID: " + notificationInfo.getNotificationId());
    }

    public DeepLinkListener getDeepLinkListener() {
        return mDeepLinkListener;
    }
}