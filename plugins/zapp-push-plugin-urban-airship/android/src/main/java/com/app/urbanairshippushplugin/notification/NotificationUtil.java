package com.app.urbanairshippushplugin.notification;

import android.app.Notification;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.view.View;
import android.widget.RemoteViews;

import androidx.core.app.NotificationCompat;

import com.applicaster.app.CustomApplication;
import com.applicaster.storage.LocalStorage;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.NotificationTarget;
import com.urbanairship.push.PushMessage;

import java.text.SimpleDateFormat;

public class NotificationUtil {

    public static final String TAG = "NotificationUtil";
    private static final String CUSTOM_SOUND_KEY = "custom sound";
    private static final String SILENT_PUSH_KEY = "silent";
    private static final String DEFAULT_SND = "system_default";
    private static final String PUSH_NOTIFICATIONS_ENABLED = "push_notifications_enabled";

    public static Notification createCustomNotification(final Context context,
                                                        String title,
                                                        String description,
                                                        Uri sound,
                                                        final String imgUrl,
                                                        final int notificationIconId,
                                                        final int notificationId,
                                                        String channelId,
                                                        String notificationCustomLayout,
                                                        String notificationCustomBigLayout) {

        final RemoteViews normalRemoteViews = getNotificationView(context, title, description, notificationIconId, notificationCustomLayout);
        final RemoteViews bigRemoteViews = getNotificationView(context, title, description, notificationIconId, notificationCustomBigLayout);

        final NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, channelId)
                // Set Icon
                .setSmallIcon(notificationIconId)
                .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), notificationIconId))
                // Dismiss Notification
                .setAutoCancel(true)
                // Set RemoteViews into Notification
                .setContent(normalRemoteViews)
                // Set the alert to alert only once
                .setOnlyAlertOnce(true)
                //set defaults for lights and vibrations.
                .setDefaults(Notification.DEFAULT_LIGHTS | Notification.DEFAULT_VIBRATE)
                //set the sound
                .setSound(sound);

        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
            notificationBuilder.setCustomBigContentView(bigRemoteViews);
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder.setColor(context.getResources().getColor(OSUtil.getColorResourceIdentifier("notification_icon_background")));
        }

        final Notification notification = notificationBuilder.build();

        if (!StringUtil.isEmpty(imgUrl)) {
            normalRemoteViews.setViewVisibility(OSUtil.getResourceId("custom_notification_image"), View.VISIBLE);
            bigRemoteViews.setViewVisibility(OSUtil.getResourceId("custom_notification_image"), View.VISIBLE);

            Runnable runnable = new Runnable() {

                @Override
                public void run() {
                    NotificationTarget notificationTarget = new NotificationTarget(context,
                            OSUtil.getResourceId("custom_notification_image"), normalRemoteViews, notification, notificationId);
                    NotificationTarget notificationTarget2 = new NotificationTarget(context,
                            OSUtil.getResourceId("custom_notification_image"), bigRemoteViews, notification, notificationId);

                    Glide.with(context.getApplicationContext()).asBitmap().load(imgUrl).into(notificationTarget);
                    Glide.with(context.getApplicationContext()).asBitmap().load(imgUrl).into(notificationTarget2);

                }
            };
            Handler mainHandler = new Handler(context.getMainLooper());
            mainHandler.post(runnable);
        }

        return notification;
    }

    private static RemoteViews getNotificationView(Context context, String title, String description, int notificationIconId, String notificationLayout) {
        RemoteViews remoteViews = new RemoteViews(OSUtil.getPackageName(), OSUtil.getLayoutResourceIdentifier(notificationLayout));
        remoteViews.setImageViewResource(OSUtil.getResourceId("custom_notification_app_icon"), notificationIconId);
        remoteViews.setTextViewText(OSUtil.getResourceId("custom_notification_title"), title);
        remoteViews.setTextViewText(OSUtil.getResourceId("custom_notification_description"), description);
        remoteViews.setTextViewText(OSUtil.getResourceId("custom_notification_time"),
                new SimpleDateFormat(
                        context.getResources().getString(OSUtil.getStringResourceIdentifier("hourDateFormat")),
                        CustomApplication.getApplicationLocale()).format(System.currentTimeMillis()));

        return remoteViews;
    }

    public static Uri getPushSound(PushMessage message, Context context) {
        //no sound push
        if (isSilent(message)) {
            return null;
        }
        //custom sound push
        Uri custom = getSoundUriByName(message.getPushBundle().getString(CUSTOM_SOUND_KEY), context);
        if (custom != null) {
            return custom;
        }
        //Default
        return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
    }

    public static Uri getSoundUri(String sound, Context context){
        if(StringUtil.isEmpty(sound) || DEFAULT_SND.equalsIgnoreCase(sound)) {
            return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        }

        //no sound push
        if (SILENT_PUSH_KEY.equalsIgnoreCase(sound)) {
            return null;
        }
        //custom sound push
        Uri custom = getSoundUriByName(sound, context);
        if (custom != null) {
            return custom;
        }
        //Default
        return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
    }

    private static boolean isSilent(PushMessage message) {
        return SILENT_PUSH_KEY.equalsIgnoreCase(message.getPushBundle().getString(CUSTOM_SOUND_KEY));
    }

    private static Uri getSoundUriByName(String soundName, Context context) {
        Uri res = null;
        if (StringUtil.isEmpty(soundName)) {
            return res;
        }
        int id = context.getResources().getIdentifier(soundName, "raw", context.getPackageName());
        if (id != 0) {
            res = Uri.parse("android.resource://" + context.getPackageName() + "/" + id);
        }
        return res;
    }

}
