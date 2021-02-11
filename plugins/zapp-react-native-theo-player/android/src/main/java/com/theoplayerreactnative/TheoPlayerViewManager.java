package com.theoplayerreactnative;

import android.app.Activity;
import android.app.Application;
import android.os.Build;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.mediarouter.media.MediaRouter;

import com.applicaster.reactnative.utils.ContainersUtil;
import com.applicaster.util.APLogger;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.theoplayer.android.api.THEOplayerConfig;
import com.theoplayer.android.api.THEOplayerView;
import com.theoplayer.android.api.ads.AdsConfiguration;
import com.theoplayer.android.api.cast.CastStrategy;
import com.theoplayer.android.api.event.player.PlayerEventTypes;
import com.theoplayer.android.api.player.Player;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.analytics.AnalyticsDescription;
import com.theoplayer.android.api.source.analytics.ConvivaConfiguration;
import com.theoplayer.android.api.source.analytics.ConvivaContentMetadata;
import com.theoplayer.android.api.source.analytics.MoatOptions;
import com.theoplayer.android.api.source.analytics.YouboraOptions;
import com.theoplayer.android.internal.activity.CurrentActivityHelper;
import com.theoplayerreactnative.events.EventRouter;
import com.theoplayerreactnative.events.EventsBinder;
import com.theoplayerreactnative.utility.JSON2RN;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class TheoPlayerViewManager extends SimpleViewManager<THEOplayerView> implements LifecycleEventListener {

    //static
    private static final String RCT_MODULE_NAME = "THEOplayerView";
    private static final String JavaScriptMessageListener = "onJSMessageReceived";
    public static final String TAG = RCT_MODULE_NAME;

    private enum InternalAndGlobalEventPair {
        onPlayerPlay(new EventRouter<>(PlayerEventTypes.PLAY, EventsBinder::toRN)),
        onPlayerPlaying(new EventRouter<>(PlayerEventTypes.PLAYING, EventsBinder::toRN)),
        onPlayerPause(new EventRouter<>(PlayerEventTypes.PAUSE, EventsBinder::toRN)),
        onPlayerProgress(new EventRouter<>(PlayerEventTypes.PROGRESS, EventsBinder::toRN)),
        onPlayerSeeking(new EventRouter<>(PlayerEventTypes.SEEKING, EventsBinder::toRN)),
        onPlayerSeeked(new EventRouter<>(PlayerEventTypes.SEEKED, EventsBinder::toRN)),
        onPlayerWaiting(new EventRouter<>(PlayerEventTypes.WAITING, EventsBinder::toRN)),
        onPlayerTimeUpdate(new EventRouter<>(PlayerEventTypes.TIMEUPDATE, EventsBinder::toRN)),
        onPlayerRateChange(new EventRouter<>(PlayerEventTypes.RATECHANGE, EventsBinder::toRN)),
        onPlayerReadyStateChange(new EventRouter<>(PlayerEventTypes.READYSTATECHANGE, EventsBinder::toRN)),
        onPlayerLoadedMetaData(new EventRouter<>(PlayerEventTypes.LOADEDMETADATA, EventsBinder::toRN)),
        onPlayerLoadedData(new EventRouter<>(PlayerEventTypes.LOADEDDATA, EventsBinder::toRN)),
        onPlayerLoadStart(new EventRouter<>(PlayerEventTypes.LOADSTART, EventsBinder::toRN)),
        onPlayerCanPlay(new EventRouter<>(PlayerEventTypes.CANPLAY, EventsBinder::toRN)),
        onPlayerCanPlayThrough(new EventRouter<>(PlayerEventTypes.CANPLAYTHROUGH, EventsBinder::toRN)),
        onPlayerDurationChange(new EventRouter<>(PlayerEventTypes.DURATIONCHANGE, EventsBinder::toRN)),
        onPlayerSourceChange(new EventRouter<>(PlayerEventTypes.SOURCECHANGE, EventsBinder::toRN)),
        onPlayerPresentationModeChange(new EventRouter<>(PlayerEventTypes.PRESENTATIONMODECHANGE, EventsBinder::toRN)),
        onPlayerVolumeChange(new EventRouter<>(PlayerEventTypes.VOLUMECHANGE, EventsBinder::toRN)),
        onPlayerDestroy(new EventRouter<>(PlayerEventTypes.DESTROY, EventsBinder::toRN)),
        onPlayerEnded(new EventRouter<>(PlayerEventTypes.ENDED, EventsBinder::toRN)),
        onPlayerError(new EventRouter<>(PlayerEventTypes.ERROR, EventsBinder::toRN)),

        // non-player events
        onPlayerResize( null),
        onJSWindowEvent(null);

        @NonNull
        String internalEvent;
        @NonNull
        String globalEvent;
        @Nullable
        EventRouter<?> router;

        InternalAndGlobalEventPair(@Nullable EventRouter<?> router) {
            this.globalEvent = name();
            this.internalEvent = name() + "Internal";
            this.router = router;
        }

    }

    THEOplayerView playerView;

    @Override
    @NonNull
    public String getName() {
        return RCT_MODULE_NAME;
    }

    @Override
    @NonNull
    protected THEOplayerView createViewInstance(@NotNull final ThemedReactContext reactContext) {
        String license = PluginHelper.getLicense();
        if(TextUtils.isEmpty(license)) {
            APLogger.error(TAG, "Empty license key");
        }

        List<AnalyticsDescription> analytics = getAnalytics();

        /*
          If you want to use Google Ima set googleIma in theoplayer config(uncomment line below) and add `integration: "google-ima"`
          in js ads source declaration.
          You can declare in THEOplayer configuration builder default js and css paths by using cssPaths() and jsPaths()
        */
        THEOplayerConfig playerConfig = new THEOplayerConfig.Builder()
                .ads(new AdsConfiguration.Builder().build())
                .license(license)
                .castStrategy(CastStrategy.AUTO)
                .analytics(analytics.toArray(new AnalyticsDescription[0]))
                .jsPaths("file:///android_asset/script.js")
                .cssPaths("file:///android_asset/style.css")
                .build();

        final Activity currentActivity = reactContext.getCurrentActivity();
        playerView = new THEOplayerView(currentActivity, playerConfig);
        playerView.setLayoutParams(new LinearLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        playerView.addJavaScriptMessageListener(JavaScriptMessageListener, event -> {
            APLogger.debug(TAG, "Received JS event " + event);
            reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(InternalAndGlobalEventPair.onJSWindowEvent.internalEvent, repackEvent(event));
        });
        playerView.evaluateJavaScript("init({player: player})", null);
        addPropertyChangeListeners(reactContext);
        reactContext.addLifecycleEventListener(this);
        goFullscreen(currentActivity);

        hackChromecast(currentActivity);
        return playerView;
    }

    private void hackChromecast(Activity currentActivity) {
        CurrentActivityHelper instance = CurrentActivityHelper.getInstance();
        try{
            if(null != instance) {
                if(null != instance.getLastResumedActivity()) {
                    return;
                }
                Field f = instance.getClass().getDeclaredField("lastResumedActivityHolder");
                f.setAccessible(true);
                Application.ActivityLifecycleCallbacks handler = (Application.ActivityLifecycleCallbacks) f.get(instance);
                if (handler != null) {
                    handler.onActivityResumed(currentActivity);
                }
            }
        } catch (IllegalAccessException | NoSuchFieldException e) {
            e.printStackTrace();
        }
    }

    @NotNull
    private List<AnalyticsDescription> getAnalytics() {
        List<AnalyticsDescription> analytics = new ArrayList<>();
        String moatCode = PluginHelper.getMoat();
        if(!TextUtils.isEmpty(moatCode)) {
            // namespace is not used internally, probably removed from Moat SDK
            analytics.add(new MoatOptions.Builder("", moatCode).build());
        }

        /*
          Example conviva usage, add account code & uncomment analytics config declaration, if you need
          custom conviva metadata add customConvivaMetadata with key and value
        */
        HashMap<String, String> customConvivaMetadata = new HashMap<>();
        //customConvivaMetadata.put("<KEY>", "<VALUE>");

         /*
          Example youbora usage, add account code & uncomment analytics config declaration
        */
        ConvivaConfiguration conviva = new ConvivaConfiguration.Builder("<Your conviva account code>",
                new ConvivaContentMetadata.Builder("THEOPlayer")
                        .applicationName("THEOPlayer demo")
                        .live(false)
                        .custom(customConvivaMetadata)
                        .build())
                .gatewayUrl("<Your gateway url>")
                .heartbeatInterval(5)
                .manualSessionControl(false)
                .build();

        /*
          Example youbora usage, add account code & uncomment analytics config declaration
        */
        YouboraOptions youbora = YouboraOptions.Builder.youboraOptions("<Your youbora account code>")
                .put("enableAnalytics", "true")
                .put("username", "THEO user")
                .put("content.title", "Demo")
                .build();
        return analytics;
    }

    @ReactProp(name = "autoplay", defaultBoolean = false)
    public void setAutoplay(View view, boolean autoplay) {
        playerView.getPlayer().setAutoplay(autoplay);
    }

    @ReactProp(name = "fullscreenOrientationCoupling", defaultBoolean = false)
    public void setFullscreenOrientationCoupling(View view, boolean fullscreenOrientationCoupling) {
        playerView.getSettings().setFullScreenOrientationCoupled(fullscreenOrientationCoupling);
    }

    @ReactProp(name = "source")
    public void setSource(View view, ReadableMap source) {
        SourceDescription sourceDescription = SourceHelper.parseSourceFromJS(source);
        if (sourceDescription != null) {
            playerView.getPlayer().setSource(sourceDescription);
        }
    }

    public Map<String, Object> getExportedCustomBubblingEventTypeConstants() {
        MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
        for (InternalAndGlobalEventPair e : InternalAndGlobalEventPair.values())
            builder.put(e.internalEvent,
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", e.globalEvent)));
        return builder.build();
    }

    //lifecycle events
    @Override
    public void onHostResume() {
        playerView.onResume();
    }

    @Override
    public void onHostPause() {
        playerView.onPause();
    }

    @Override
    public void onHostDestroy() {
        playerView.onDestroy();
    }

    private void goFullscreen(Activity currentActivity) {
        playerView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LOW_PROFILE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN);

        playerView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(View v) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    currentActivity
                            .getWindow()
                            .getAttributes()
                            .layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
                }
            }

            @Override
            public void onViewDetachedFromWindow(View v) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    currentActivity
                            .getWindow()
                            .getAttributes()
                            .layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
                }
            }
        });
    }

    private Object repackEvent(String eventJSON) {
        try {
            // todo: simplify and convert directly from JSONObject to WritableNativeMap
            JSONObject jsonObject = new JSONObject(eventJSON);
            Map<String, Object> map = JSON2RN.toMap(jsonObject);
            return ContainersUtil.INSTANCE.toRN(map);
        } catch (JSONException e) {
            APLogger.error(TAG, "failed to load convert JSON event", e);
            e.printStackTrace();
        }
        return eventJSON; // try to pass as primitive
    }

    private void addPropertyChangeListeners(final ThemedReactContext reactContext) {
        Player player = playerView.getPlayer();
        for(InternalAndGlobalEventPair p :InternalAndGlobalEventPair.values()){
            if(null != p.router)
                p.router.subscribe(player, playerView, reactContext, p.internalEvent);
        }
        playerView.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
            WritableMap map = Arguments.createMap();
            map.putInt("left", left);
            map.putInt("top", top);
            map.putInt("right", right);
            map.putInt("bottom", bottom);
            reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(InternalAndGlobalEventPair.onPlayerResize.internalEvent, map);
        });
    }
}
