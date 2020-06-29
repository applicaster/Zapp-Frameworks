package com.applicaster.chromecast;

import androidx.annotation.Nullable;
import androidx.mediarouter.media.MediaControlIntent;
import androidx.mediarouter.media.MediaRouteSelector;
import androidx.mediarouter.media.MediaRouter;

import com.applicaster.chromecast.analytics.Analytics;
import com.applicaster.plugin_manager.GenericPluginI;
import com.applicaster.plugin_manager.Plugin;
import com.applicaster.plugin_manager.PluginManager;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppContext;
import com.google.android.gms.cast.framework.CastContext;

import java.util.HashMap;
import java.util.Map;

public class ChromeCastPlugin implements GenericPluginI {

    private static final String TAG = "ChromeCastPlugin";
    private static final String SELF_ID = "chromecast_qb";
    private static final String CHROMECAST_APP_ID = "chromecast_app_id";

    private final MediaRouteSelector mSelector;

    private Map<String, String> mConfiguration = new HashMap<>();

    private Analytics mAnalytics;

    // needed only to force the app to scan
    private final MediaRouter.Callback mScanCallback = new MediaRouter.Callback() {
        @Override
        public void onRouteSelected(MediaRouter router, MediaRouter.RouteInfo route) {
            super.onRouteSelected(router, route);
        }
    };

    public ChromeCastPlugin(){
        mSelector = new MediaRouteSelector.Builder()
                // These are the framework-supported intents
                .addControlCategory(MediaControlIntent.CATEGORY_REMOTE_PLAYBACK)
                .build();
    }

    public void setPluginModel(Plugin plugin) {
        if(!SELF_ID.equals(plugin.identifier)){
            APLogger.error(TAG, "ChromeCastPlugin plugin id does not match: " +
                    SELF_ID + " expected, got " +
                    plugin.identifier);
        }
        if(null != plugin.configuration) {
            mConfiguration = plugin.configuration;
        }
    }

    public static ChromeCastPlugin getInstance() {
        PluginManager.InitiatedPlugin initiatedPlugin = PluginManager.getInstance().getInitiatedPlugin(SELF_ID);
        if(null == initiatedPlugin) {
            APLogger.error(TAG, "ChromeCastPlugin getInstance called before plugin is initialized");
            return null;
        }
        return (ChromeCastPlugin) initiatedPlugin.getInstance();
    }

    public String getAppId() {
        return mConfiguration.get(CHROMECAST_APP_ID);
    }

    public void onResume() {
        getMediaRouter()
                .addCallback(mSelector, mScanCallback, MediaRouter.CALLBACK_FLAG_REQUEST_DISCOVERY);
        if(null == mAnalytics) {
            mAnalytics = new Analytics(CastContext.getSharedInstance(AppContext.get()));
        }
        mAnalytics.hostResume();
    }

    public void onPause() {
        getMediaRouter()
                .removeCallback(mScanCallback);
        mAnalytics.hostPause();
    }

    private MediaRouter getMediaRouter() {
        return MediaRouter.getInstance(AppContext.get());
    }

    @Nullable
    public Analytics getAnalytics() {
        return mAnalytics;
    }
}
