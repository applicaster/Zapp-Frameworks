package com.app.urbanairshippushplugin.factories;

import android.app.Notification;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;

import com.app.urbanairshippushplugin.Constant;
import com.app.urbanairshippushplugin.notification.NotificationUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.urbanairship.json.JsonException;
import com.urbanairship.json.JsonMap;
import com.urbanairship.json.JsonValue;
import com.urbanairship.push.PushMessage;
import com.urbanairship.push.notifications.NotificationFactory;

import java.util.Map;
import java.util.Random;

import static com.app.urbanairshippushplugin.UrbanAirshipPushProvider.URBAN_DEFAULT_CHANNEL_ID;

public class UrbanPluginCustomNotificationFactory extends NotificationFactory {
    private static final String TAG = "UrbanPluginCustomNotificationFactory";

    private final Context mContext;
    private final Map<String, Uri> mChannelSounds;
    private int  mNotificationID;
    private String customNotificationLayout;
    private String bigCustomNotificationLayout;

    public UrbanPluginCustomNotificationFactory(@NonNull Context context,
                                                @NonNull Map<String, Uri> channelSounds,
                                                @NonNull String customNotificationLayout,
                                                @NonNull String bigCustomNotificationLayout) {
        super(context);
        mContext = context;
        mChannelSounds = channelSounds;
        this.customNotificationLayout = customNotificationLayout;
        this.bigCustomNotificationLayout = bigCustomNotificationLayout;
    }

    @Override
    public Notification createNotification(@NonNull PushMessage message, int notificationId) {
        String alert = message.getAlert();
        String stylePayload = message.getStylePayload();

        if (StringUtil.isEmpty(alert)) {
            return null;
        }

        String channelId = message.getNotificationChannel();
        if(null == channelId){
            channelId = URBAN_DEFAULT_CHANNEL_ID;
        }

        if(!mChannelSounds.containsKey(channelId)) {
            APLogger.warn(TAG, "Push notification Channel id " + channelId + " is missing in Urban Airship plugin settings");
        }

        JsonMap styleJson;
        try {
            styleJson = JsonValue.parseString(stylePayload).optMap();
        } catch (JsonException e) {
            APLogger.error(TAG, "Failed to parse notification style payload." + e);
            return null;
        }

        String imgUrl = styleJson.opt(Constant.BIG_PICTURE_KEY).getString();

        // override sound with channel one, if any
        Uri sound = mChannelSounds.get(channelId);
        if(null == sound) {
            sound = NotificationUtil.getPushSound(message, mContext);
        }

        return NotificationUtil.createCustomNotification(mContext, "",
                alert,
                sound,
                imgUrl,
                OSUtil.getDrawableResourceIdentifier("notification_icon"),
                mNotificationID, //todo: why not notificationId?
                channelId,
                customNotificationLayout,
                bigCustomNotificationLayout);
    }

    private int getNotificationID() {
        Random rand = new Random();
        return rand.nextInt(10000) + 1;
    }

    @Override
    public int getNextId(@NonNull PushMessage pushMessage) {
        mNotificationID = getNotificationID();
        return mNotificationID;
    }
}
