package com.app.urbanairshippushplugin;

import android.app.Application;
import android.content.Context;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationManagerCompat;

import com.app.urbanairshippushplugin.factories.UrbanPluginCustomNotificationFactory;
import com.app.urbanairshippushplugin.factories.UrbanPluginDefaultNotificationFactory;
import com.app.urbanairshippushplugin.reciver.PluginAirshipReceiver;
import com.applicaster.app.APProperties;
import com.applicaster.plugin_manager.push_plugin.PushContract;
import com.applicaster.plugin_manager.push_plugin.helper.PushPluginsType;
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagLoadedI;
import com.applicaster.plugin_manager.push_plugin.listeners.PushTagRegistrationI;
import com.applicaster.util.APDebugUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppData;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.google.firebase.FirebaseApp;
import com.urbanairship.AirshipConfigOptions;
import com.urbanairship.UAirship;
import com.urbanairship.push.PushManager;
import com.urbanairship.push.fcm.FcmPushProvider;
import com.urbanairship.push.notifications.NotificationChannelCompat;
import com.urbanairship.push.notifications.NotificationChannelRegistry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.app.urbanairshippushplugin.notification.NotificationUtil.getSoundUri;


/**
 * Created by elad kariti on 11/27/16.
 */
public class UrbanAirshipPushProvider implements PushContract {

    private static final String TAG = "UrbanAirshipPushProvider";

    private static final String CHANNEL_NAME_KEY = "notification_channel_name";
    private static final String CHANNEL_ID_KEY = "notification_channel_id";
    private static final String CHANNEL_SOUND_KEY = "notification_channel_sound";
    private static final String CHANNEL_IMPORTANCE_KEY = "notification_channel_importance";
    private static final String DEFAULT_CHANNEL_NAME = "Push Notifications";
    public static final String URBAN_DEFAULT_CHANNEL_ID = "urban_default";

    // notification channel priorities
    private static final String PRIORITY_HIGH = "high";
    private static final String PRIORITY_DEFAULT = "default";
    private static final String PRIORITY_LOW = "low";
    private static final String PRIORITY_MIN = "min";

    private Map<String, String> mMapParams;
    private Context mContext;

    // Map of sounds assigned to channels in zapp to be used for Android < 8.0
    // Android 8.0+ will take sound from the channel and ignore notification one
    private final Map<String, Uri> mChannelSounds = new HashMap<>();

    @Override
    public void initPushProvider(final Context context) {
        mContext = context;

        String devKey = getParamByKey(Constant.DEBUG_KEY);
        String devSecret = getParamByKey(Constant.DEBUG_SECRET);

        String proKey = getParamByKey(Constant.PRO_KEY);
        String proSecret = getParamByKey(Constant.PRO_SECRET);

        APLogger.info(TAG, "initPushProvider");
        AirshipConfigOptions options = new AirshipConfigOptions.Builder()
                .setDevelopmentAppKey(devKey)
                .setAutoLaunchApplication(true)
                .setDevelopmentAppSecret(devSecret)
                .setProductionAppKey(proKey)
                .setProductionAppSecret(proSecret)
                .setDevelopmentLogLevel(1).setProductionLogLevel(1).setInProduction(isProduction())
                .setFcmSenderId(AppData.getProperty(APProperties.GOOGLE_API_PROJECT_NUMBER)) // FCM sender ID
                .setNotificationIcon(OSUtil.getDrawableResourceIdentifier(Constant.PUSH_ICON))
                .setNotificationAccentColor(context.getResources().getColor(OSUtil.getColorResourceIdentifier(Constant.PUSH_BG_COLOR)))
                .setCustomPushProvider(new FcmPushProvider())
                .build();
        FirebaseApp.initializeApp(context);
        UAirship.takeOff((Application) context.getApplicationContext(), options, new UAirship.OnReadyCallback() {
            @Override
            public void onAirshipReady(@NonNull UAirship uAirship) {
                PushManager pushManager = uAirship.getPushManager();
                pushManager.setUserNotificationsEnabled(true);
                PluginAirshipReceiver receiver = new PluginAirshipReceiver(context);
                pushManager.setNotificationListener(receiver);
                pushManager.addPushListener(receiver);
                uAirship.getChannel().addChannelListener(receiver);
                uAirship.setDeepLinkListener(receiver.getDeepLinkListener());
                updateNotificationLayout(uAirship);
                buildSoundLookup();
                ensureChannels(uAirship.getPushManager().getNotificationChannelRegistry());
                signForUrbanConnect();
            }
        });
    }

    private void buildSoundLookup() {
        // Custom channels
        for(int i = 1; ; ++i) {
            String channelId = getParamByKey(CHANNEL_ID_KEY + "_" + i);
            if(StringUtil.isEmpty(channelId)) {
                break;
            }
            String sound = getParamByKey(CHANNEL_SOUND_KEY + "_" + i);
            Uri soundUrl = getSoundUri(sound, mContext);
            if (soundUrl != null) {
                mChannelSounds.put(channelId, soundUrl);
            }
        }
        // Default channel
        String sound = getParamByKey(CHANNEL_SOUND_KEY);
        Uri soundUrl = getSoundUri(sound, mContext);
        if(null != soundUrl) {
            mChannelSounds.put(URBAN_DEFAULT_CHANNEL_ID, soundUrl);
        }
    }

    private void ensureChannels(NotificationChannelRegistry notificationChannelRegistry) {
        // create all the custom channels, if any
        for(int i = 1; ; ++i) {
            String channelName = getParamByKey(CHANNEL_NAME_KEY + "_" + i);
            if(StringUtil.isEmpty(channelName)) {
                break;
            }
            String channelId = getParamByKey(CHANNEL_ID_KEY + "_" + i);
            if(StringUtil.isEmpty(channelId)) {
                break;
            }

            String importance = getParamByKey(CHANNEL_IMPORTANCE_KEY + "_" + i);
            String sound = getParamByKey(CHANNEL_SOUND_KEY + "_" + i);
            Uri soundUrl = getSoundUri(sound, mContext);

            NotificationChannelCompat channelCompat = new NotificationChannelCompat(
                    channelId,
                    channelName,
                    getImportanceId(importance));
            channelCompat.setSound(soundUrl);
            notificationChannelRegistry.createNotificationChannel(channelCompat);
        }

        // create default channel (backward compatibility for plugin settings)
        String paramChannelName = getParamByKey(CHANNEL_NAME_KEY);

        String sound = getParamByKey(CHANNEL_SOUND_KEY);
        Uri soundUrl = getSoundUri(sound, mContext);

        NotificationChannelCompat channelCompat = new NotificationChannelCompat(
                URBAN_DEFAULT_CHANNEL_ID,
                StringUtil.isEmpty(paramChannelName) ? DEFAULT_CHANNEL_NAME : paramChannelName,
                NotificationManagerCompat.IMPORTANCE_DEFAULT);
        channelCompat.setSound(soundUrl);
        notificationChannelRegistry.createNotificationChannel(channelCompat);
    }

    private static int getImportanceId(String importance) {
        if(StringUtil.isEmpty(importance)) {
            return NotificationManagerCompat.IMPORTANCE_DEFAULT;
        }
        switch(importance.toLowerCase()) {
            case PRIORITY_HIGH:
                return  NotificationManagerCompat.IMPORTANCE_HIGH;
            case PRIORITY_DEFAULT:
                return NotificationManagerCompat.IMPORTANCE_DEFAULT;
            case PRIORITY_LOW:
                return NotificationManagerCompat.IMPORTANCE_LOW;
            case PRIORITY_MIN:
                return NotificationManagerCompat.IMPORTANCE_MIN;
        }
        return NotificationManagerCompat.IMPORTANCE_DEFAULT;
    }

    private void signForUrbanConnect() {
        String googleAccountID = getParamByKey(Constant.URBAN_CONNECT_ID);
        if (StringUtil.isNotEmpty(googleAccountID)) {
            UAirship.shared().getAnalytics()
                    .editAssociatedIdentifiers()
                    .addIdentifier("GA_CID", googleAccountID)
                    .apply();
        }
    }

    private boolean isProduction() {
        return !APDebugUtil.getIsInDebugMode();
    }

    private void updateNotificationLayout(UAirship uAirship) {
        String notificationStyle = getParamByKey(Constant.NOTIFICATION_STYLE);
        switch (UrbanNotificationStyle.getType(notificationStyle)) {
            case CustomImage:
                uAirship.getPushManager().setNotificationFactory(new UrbanPluginCustomNotificationFactory(mContext, mChannelSounds,
                        "custom_notification_layout", "big_custom_notification_layout"));
                break;
            case CustomOneImage:
                uAirship.getPushManager().setNotificationFactory(new UrbanPluginCustomNotificationFactory(mContext, mChannelSounds,
                        "custom_one_notification_layout", "big_custom_one_notification_layout"));
                break;
            default:
                uAirship.getPushManager().setNotificationFactory(new UrbanPluginDefaultNotificationFactory(mContext, mChannelSounds));
        }
    }

    @Override
    public void registerPushProvider(Context context, String registerID) {
        APLogger.info(TAG, "registerPushProvider - registerID: " + registerID);
        initPushProvider(context);
    }


    @Override
    public void setPluginParams(Map params) {
        APLogger.info(TAG, "setPluginParams - params: " + params.toString());
        mMapParams = params;
    }

    @Override
    public void addTagToProvider(Context context, List<String> tag, PushTagRegistrationI pushTagRegistrationListener) {
        Set<String> tagsArray = new HashSet<String>(tag);
        APLogger.info(TAG, "addTagToProvider - tags: " + tagsArray.toString());
        try {
            UAirship.shared().getPushManager().editTags()
                    .addTags(tagsArray)
                    .apply();
            pushTagRegistrationListener.pushRregistrationTagComplete(PushPluginsType.urbanAirship, true);
        } catch (Exception e) {
            pushTagRegistrationListener.pushRregistrationTagComplete(PushPluginsType.urbanAirship, false);
        }
    }

    @Override
    public void removeTagToProvider(Context context, List<String> tag, PushTagRegistrationI pushTagRegistrationListener) {
        Set<String> tagsArray = new HashSet<String>(tag);
        APLogger.info(TAG, "removeTagToProvider - tags: " + tagsArray.toString());
        try {
            UAirship.shared().getPushManager().editTags()
                    .removeTags(tagsArray)
                    .apply();
            pushTagRegistrationListener.pushUnregistrationTagComplete(PushPluginsType.urbanAirship, true);
        } catch (Exception e) {
            pushTagRegistrationListener.pushUnregistrationTagComplete(PushPluginsType.urbanAirship, false);
        }

    }

    @Override
    public PushPluginsType getPluginType() {
        return PushPluginsType.urbanAirship;
    }

    @Override
    public void getTagList(Context context, PushTagLoadedI listener) {
        try {
            Set<String> tagsArray = UAirship.shared().getPushManager().getTags();
            listener.tagLoaded(PushPluginsType.urbanAirship, new ArrayList<String>(tagsArray));
        } catch (Exception e) {
            listener.tagLoaded(PushPluginsType.urbanAirship, null);
        }
    }

    public String getParamByKey(String key) {
        String result = "";
        if (mMapParams.containsKey(key)) {
            result = mMapParams.get(key);
        }
        return result;
    }

    @Override
    public void setPushEnabled(Context context, boolean isEnabled) {
        UAirship.shared().getPushManager().setPushEnabled(isEnabled);
    }
}
