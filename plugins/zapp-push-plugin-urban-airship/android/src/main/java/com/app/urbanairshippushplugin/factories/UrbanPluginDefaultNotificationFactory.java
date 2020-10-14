package com.app.urbanairshippushplugin.factories;

import android.app.Notification;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.app.urbanairshippushplugin.notification.NotificationUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.OSUtil;
import com.urbanairship.push.PushMessage;
import com.urbanairship.push.notifications.NotificationFactory;
import com.urbanairship.util.UAStringUtil;

import java.util.Map;

public class UrbanPluginDefaultNotificationFactory extends NotificationFactory {

    private static final String TAG = UrbanPluginDefaultNotificationFactory.class.getSimpleName();
    private final Context context;
    private final Map<String, Uri> mChannelSounds;

    public UrbanPluginDefaultNotificationFactory(Context mContext, Map<String, Uri> channelSounds) {
        super(mContext);
        context = mContext;
        mChannelSounds = channelSounds;
    }

    public NotificationCompat.Builder extendBuilder(@NonNull NotificationCompat.Builder builder,
                                                    @NonNull PushMessage message,
                                                    int notificationId) {

        Uri pushSound = NotificationUtil.getPushSound(message, context);

        // override sound with channel one, if any
        String channelId = message.getNotificationChannel();
        if(null != channelId) {
            builder.setChannelId(channelId);
            Uri soundUri = mChannelSounds.get(channelId);
            if(null != soundUri) {
                pushSound = soundUri;
            }
            if(!mChannelSounds.containsKey(channelId)) {
                APLogger.warn(TAG, "Push notification Channel id " + channelId + " is missing in Urban Airship plugin settings");
            }

        }
        // does not work for Android 8+, system uses sound from the channel
        return builder.setSound(pushSound);
    }

    @Override
    public int getSmallIconId() {
        return OSUtil.getDrawableResourceIdentifier("notification_icon");
    }

    @Override
    public void setNotificationDefaultOptions(int defaults) {
        super.setNotificationDefaultOptions(Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS);
    }

    @Override
    public final Notification createNotification(@NonNull PushMessage message, int notificationId) {
        if (UAStringUtil.isEmpty(message.getAlert())) {
            return null;
        } else {
            NotificationCompat.Builder builder = this.createNotificationBuilder(message, notificationId, (new NotificationCompat.BigTextStyle()).bigText(message.getAlert()));
            return this.extendBuilder(builder, message, notificationId).build();
        }
    }
}
