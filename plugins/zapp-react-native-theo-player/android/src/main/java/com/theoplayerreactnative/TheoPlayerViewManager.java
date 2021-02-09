package com.theoplayerreactnative;

import android.app.Activity;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
import com.theoplayer.android.api.event.player.PlayerEventTypes;
import com.theoplayer.android.api.player.DoneCallback;
import com.theoplayer.android.api.player.Player;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.analytics.ConvivaConfiguration;
import com.theoplayer.android.api.source.analytics.ConvivaContentMetadata;
import com.theoplayer.android.api.source.analytics.YouboraOptions;
import com.theoplayerreactnative.events.EventRouter;
import com.theoplayerreactnative.events.EventsBinder;

import java.util.HashMap;
import java.util.Map;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class TheoPlayerViewManager extends SimpleViewManager<THEOplayerView> implements LifecycleEventListener {

    //static
    private static final String RCT_MODULE_NAME = "THEOplayerView";
    private static final String JavaScriptMessageListener = "FIRE";

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
    protected THEOplayerView createViewInstance(final ThemedReactContext reactContext) {
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
        /*
          If you want to use Google Ima set googleIma in theoplayer config(uncomment line below) and add `integration: "google-ima"`
          in js ads source declaration.
          You can declare in THEOplayer configuration builder default js and css paths by using cssPaths() and jsPaths()
        */
        THEOplayerConfig playerConfig = new THEOplayerConfig.Builder()
                .ads(new AdsConfiguration.Builder().build())
                //.analytics(youbora)
                .jsPaths("file:///android_asset/js/theoplayer.js")
                .cssPaths("file:///android_asset/css/theoplayer.css")
                .build();

        final Activity currentActivity = reactContext.getCurrentActivity();
        playerView = new THEOplayerView(currentActivity, playerConfig);
        playerView.setLayoutParams(new LinearLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        playerView.addJavaScriptMessageListener(JavaScriptMessageListener, event ->
                reactContext
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(InternalAndGlobalEventPair.onJSWindowEvent.internalEvent, event));
        playerView.evaluateJavaScript("init({player: player})", null);
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

        addPropertyChangeListeners(reactContext);
        reactContext.addLifecycleEventListener(this);

        goFullscreen();

        return playerView;
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
    public void onHostPause() { playerView.onPause(); }

    @Override
    public void onHostDestroy() {
        playerView.onDestroy();
    }

    private void goFullscreen() {
        playerView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LOW_PROFILE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN);
    }
}
