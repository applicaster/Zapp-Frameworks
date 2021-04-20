package com.theoplayerreactnative;

import android.app.Activity;
import android.os.Build;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.reactnative.utils.ContainersUtil;
import com.applicaster.util.APLogger;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.theoplayer.android.api.THEOplayerConfig;
import com.theoplayer.android.api.THEOplayerView;
import com.theoplayer.android.api.ads.AdsConfiguration;
import com.theoplayer.android.api.ads.GoogleImaConfiguration;
import com.theoplayer.android.api.cast.CastStrategy;
import com.theoplayer.android.api.event.ads.AdsEventTypes;
import com.theoplayer.android.api.event.player.PlayerEventTypes;
import com.theoplayer.android.api.player.Player;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.analytics.AnalyticsDescription;
import com.theoplayer.android.api.source.analytics.ConvivaConfiguration;
import com.theoplayer.android.api.source.analytics.ConvivaContentMetadata;
import com.theoplayer.android.api.source.analytics.MoatOptions;
import com.theoplayer.android.api.source.analytics.YouboraOptions;
import com.theoplayerreactnative.events.AdEventMapper;
import com.theoplayerreactnative.events.AdEventRouter;
import com.theoplayerreactnative.events.IEventRouter;
import com.theoplayerreactnative.events.PlayerEventMapper;
import com.theoplayerreactnative.events.PlayerEventRouter;
import com.theoplayerreactnative.utility.JSON2RN;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class TheoPlayerViewManager extends SimpleViewManager<THEOplayerView> implements LifecycleEventListener {

    //static
    private static final String RCT_MODULE_NAME = "THEOplayerView";
    private static final String JavaScriptMessageListener = "onJSMessageReceived";
    public static final String TAG = RCT_MODULE_NAME;

    private enum InternalAndGlobalEventPair {

        // Player events
        onPlayerPlay(new PlayerEventRouter<>(PlayerEventTypes.PLAY, PlayerEventMapper::toRN)),
        onPlayerPlaying(new PlayerEventRouter<>(PlayerEventTypes.PLAYING, PlayerEventMapper::toRN)),
        onPlayerPause(new PlayerEventRouter<>(PlayerEventTypes.PAUSE, PlayerEventMapper::toRN)),
        onPlayerProgress(new PlayerEventRouter<>(PlayerEventTypes.PROGRESS, PlayerEventMapper::toRN)),
        onPlayerSeeking(new PlayerEventRouter<>(PlayerEventTypes.SEEKING, PlayerEventMapper::toRN)),
        onPlayerSeeked(new PlayerEventRouter<>(PlayerEventTypes.SEEKED, PlayerEventMapper::toRN)),
        onPlayerWaiting(new PlayerEventRouter<>(PlayerEventTypes.WAITING, PlayerEventMapper::toRN)),
        onPlayerTimeUpdate(new PlayerEventRouter<>(PlayerEventTypes.TIMEUPDATE, PlayerEventMapper::toRN)),
        onPlayerRateChange(new PlayerEventRouter<>(PlayerEventTypes.RATECHANGE, PlayerEventMapper::toRN)),
        onPlayerReadyStateChange(new PlayerEventRouter<>(PlayerEventTypes.READYSTATECHANGE, PlayerEventMapper::toRN)),
        onPlayerLoadedMetaData(new PlayerEventRouter<>(PlayerEventTypes.LOADEDMETADATA, PlayerEventMapper::toRN)),
        onPlayerLoadedData(new PlayerEventRouter<>(PlayerEventTypes.LOADEDDATA, PlayerEventMapper::toRN)),
        onPlayerLoadStart(new PlayerEventRouter<>(PlayerEventTypes.LOADSTART, PlayerEventMapper::toRN)),
        onPlayerCanPlay(new PlayerEventRouter<>(PlayerEventTypes.CANPLAY, PlayerEventMapper::toRN)),
        onPlayerCanPlayThrough(new PlayerEventRouter<>(PlayerEventTypes.CANPLAYTHROUGH, PlayerEventMapper::toRN)),
        onPlayerDurationChange(new PlayerEventRouter<>(PlayerEventTypes.DURATIONCHANGE, PlayerEventMapper::toRN)),
        onPlayerSourceChange(new PlayerEventRouter<>(PlayerEventTypes.SOURCECHANGE, PlayerEventMapper::toRN)),
        onPlayerPresentationModeChange(new PlayerEventRouter<>(PlayerEventTypes.PRESENTATIONMODECHANGE, PlayerEventMapper::toRN)),
        onPlayerVolumeChange(new PlayerEventRouter<>(PlayerEventTypes.VOLUMECHANGE, PlayerEventMapper::toRN)),
        onPlayerDestroy(new PlayerEventRouter<>(PlayerEventTypes.DESTROY, PlayerEventMapper::toRN)),
        onPlayerEnded(new PlayerEventRouter<>(PlayerEventTypes.ENDED, PlayerEventMapper::toRN)),
        onPlayerError(new PlayerEventRouter<>(PlayerEventTypes.ERROR, PlayerEventMapper::toRN)),

        // Ads events
        onAdBreakBegin(new AdEventRouter<>(AdsEventTypes.AD_BREAK_BEGIN, AdEventMapper::toRN)),
        onAdBreakEnd(new AdEventRouter<>(AdsEventTypes.AD_BREAK_END, AdEventMapper::toRN)),
        onAdError(new AdEventRouter<>(AdsEventTypes.AD_ERROR, AdEventMapper::toRN)),
        onAdBegin(new AdEventRouter<>(AdsEventTypes.AD_BEGIN, AdEventMapper::toRN)),
        onAdEnd(new AdEventRouter<>(AdsEventTypes.AD_END, AdEventMapper::toRN)),

        // non-player events
        onPlayerResize( null),
        onJSWindowEvent(null);

        @NonNull
        String internalEvent;
        @NonNull
        String globalEvent;
        @Nullable
        IEventRouter router;

        InternalAndGlobalEventPair(@Nullable IEventRouter router) {
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

        String cssFile = "file:///android_asset/" + PluginHelper.getScaleMode() + ".css";
        String jsFile = "file:///android_asset/script.js";

        /*
          If you want to use Google Ima set googleIma in theoplayer config(uncomment line below) and add `integration: "google-ima"`
          in js ads source declaration.
          You can declare in THEOplayer configuration builder default js and css paths by using cssPaths() and jsPaths()
        */
        THEOplayerConfig playerConfig = new THEOplayerConfig.Builder()
                .ads(new AdsConfiguration.Builder()
                        .googleImaConfiguration(new GoogleImaConfiguration.Builder()
                                .useNativeIma(true)
                                .build())
                        .build())
                .license(license)
                .castStrategy(CastStrategy.AUTO)
                .analytics(analytics.toArray(new AnalyticsDescription[0]))
                .jsPaths(jsFile)
                .cssPaths(cssFile)
                .build();

        final Activity currentActivity = reactContext.getCurrentActivity();
        playerView = new THEOplayerView(currentActivity, playerConfig){
            public void requestLayout() {
                super.requestLayout();
                // This view relies on a measure + layout pass happening after it calls requestLayout().
                // https://github.com/facebook/react-native/issues/4990#issuecomment-180415510
                // https://stackoverflow.com/questions/39836356/react-native-resize-custom-ui-component
                post(measureAndLayout);
            }

            private final Runnable measureAndLayout = () -> {
                measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                        MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
                layout(getLeft(), getTop(), getRight(), getBottom());
            };
        };
        playerView.setLayoutParams(new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT));
        playerView.addJavaScriptMessageListener(JavaScriptMessageListener, event -> {
            APLogger.debug(TAG, "Received JS event " + event);
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                    playerView.getId(),
                    InternalAndGlobalEventPair.onJSWindowEvent.internalEvent,
                    repackEvent(event));
        });
        playerView.evaluateJavaScript("init({player: player})", null);
        addPropertyChangeListeners(reactContext);
        reactContext.addLifecycleEventListener(this);
        goFullscreen(currentActivity);

        return playerView;
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
        playerView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);

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
                playerView.onDestroy();
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    currentActivity
                            .getWindow()
                            .getAttributes()
                            .layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
                }
            }
        });
    }

    private WritableNativeMap repackEvent(String eventJSON) {
        try {
            // todo: simplify and convert directly from JSONObject to WritableNativeMap
            JSONObject jsonObject = new JSONObject(eventJSON);
            Map<String, Object> map = JSON2RN.toMap(jsonObject);
            return ContainersUtil.INSTANCE.toRN(map);
        } catch (JSONException e) {
            APLogger.error(TAG, "failed to load convert JSON event", e);
            throw new RuntimeException("Invalid eventJSON", e);
        }
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
