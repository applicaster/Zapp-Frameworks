package com.theoplayerreactnative;

import android.util.Log;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.LinearLayout;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import com.theoplayer.android.api.THEOplayerView;
import com.theoplayer.android.api.THEOplayerConfig;
import com.theoplayer.android.api.event.EventListener;
import com.theoplayer.android.api.event.player.PauseEvent;
import com.theoplayer.android.api.event.player.PlayEvent;
import com.theoplayer.android.api.event.player.PlayerEventTypes;
import com.theoplayer.android.api.event.player.SeekedEvent;
import com.theoplayer.android.api.event.player.PresentationModeChange;
import com.theoplayer.android.api.source.SourceDescription;
import com.theoplayer.android.api.source.analytics.YouboraOptions;
import com.theoplayer.android.api.source.analytics.ConvivaConfiguration;
import com.theoplayer.android.api.source.analytics.ConvivaContentMetadata;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

public class TheoPlayerViewManager extends SimpleViewManager<THEOplayerView> implements LifecycleEventListener {

    //static
    private static final String TAG = TheoPlayerViewManager.class.getSimpleName();
    private static final String RCT_MODULE_NAME = "THEOplayerView";

    private enum InternalAndGlobalEventPair {
        onSeek("onSeekEventInternal", "onSeek"),
        onPlay("onPlayEventInternal", "onPlay"),
        onPause("onPauseEventInternal", "onPause"),
        onPresentationModeChange("onPresentationModeChangeEventInternal", "onPresentationModeChange");

        String internalEvent;
        String globalEvent;

        InternalAndGlobalEventPair(String internalEvent, String globalEvent) {
            this.internalEvent = internalEvent;
            this.globalEvent = globalEvent;
        }
    }

    THEOplayerView playerView;

    @Override
    public String getName() {
        return RCT_MODULE_NAME;
    }

    @Override
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
          You can declarate in THEOplayer configuration builder default js and css paths by using cssPaths() and jsPaths()
        */
        THEOplayerConfig playerConfig = new THEOplayerConfig.Builder()
                // .googleIma(true)
                // .analytics(youbora)
                .jsPaths("file:///android_asset/js/theoplayer.js")
                .cssPaths("file:///android_asset/css/theoplayer.css")
                .build();

        playerView = new THEOplayerView(reactContext.getCurrentActivity(), playerConfig);
        playerView.setLayoutParams(new LinearLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        playerView.evaluateJavaScript("init({player: player})", null);

        addPropertyChangeListeners(reactContext);
        reactContext.addLifecycleEventListener(this);

        return playerView;
    }

    private void addPropertyChangeListeners(final ThemedReactContext reactContext) {
        playerView.getPlayer().addEventListener(PlayerEventTypes.SEEKED, new EventListener<SeekedEvent>() {
            @Override
            public void handleEvent(final SeekedEvent seekedEvent) {
                Log.d(TAG, "seeked native: " + seekedEvent);
                WritableMap event = Arguments.createMap();
                event.putDouble("currentTime", seekedEvent.getCurrentTime());
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                        playerView.getId(),
                        InternalAndGlobalEventPair.onSeek.internalEvent,
                        event);
            }
        });

        playerView.getPlayer().addEventListener(PlayerEventTypes.PLAY, new EventListener<PlayEvent>() {
            @Override
            public void handleEvent(final PlayEvent playEvent) {
                Log.d(TAG, "play native");
                WritableMap event = Arguments.createMap();

                //local property change
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                        playerView.getId(),
                        InternalAndGlobalEventPair.onPlay.internalEvent,
                        event);
            }
        });

        playerView.getPlayer().addEventListener(PlayerEventTypes.PAUSE, new EventListener<PauseEvent>() {
            @Override
            public void handleEvent(final PauseEvent pauseEvent) {
                Log.d(TAG, "pause native");
                WritableMap event = Arguments.createMap();
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                        playerView.getId(),
                        InternalAndGlobalEventPair.onPause.internalEvent,
                        event);
            }
        });

        playerView.getPlayer().addEventListener(PlayerEventTypes.PRESENTATIONMODECHANGE, new EventListener<PresentationModeChange>() {
            @Override
            public void handleEvent(final PresentationModeChange presentationModeChangeEvent) {
                DisplayMetrics displayMetrics = new DisplayMetrics();
                reactContext.getCurrentActivity().getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
                // Orientation detection
                int orientation = reactContext.getResources().getConfiguration().orientation;

                if(playerView.getFullScreenManager().isFullScreen()) {
                    /*
                        If needed set additional functionality when fullscreen is on, examples below
                    */
                    //playerView.getPlayer().pause();
                    //playerView.getPlayer().play();
                } else {
                    /*
                        If needed set additional functionality when fullscreen is on, examples below
                    */
                    //playerView.getPlayer().pause();
                    //playerView.getPlayer().play();
                }

                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit(InternalAndGlobalEventPair.onPresentationModeChange.internalEvent, playerView.getFullScreenManager().isFullScreen());
            }
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


    public Map getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.builder()
                .put(
                        InternalAndGlobalEventPair.onSeek.internalEvent,
                        MapBuilder.of(
                                "phasedRegistrationNames",
                                MapBuilder.of("bubbled", InternalAndGlobalEventPair.onSeek.globalEvent)))
                .put(
                        InternalAndGlobalEventPair.onPlay.internalEvent,
                        MapBuilder.of(
                                "phasedRegistrationNames",
                                MapBuilder.of("bubbled", InternalAndGlobalEventPair.onPlay.globalEvent)))
                .put(
                        InternalAndGlobalEventPair.onPause.internalEvent,
                        MapBuilder.of(
                                "phasedRegistrationNames",
                                MapBuilder.of("bubbled", InternalAndGlobalEventPair.onPause.globalEvent)))
                .put(
                        InternalAndGlobalEventPair.onPresentationModeChange.internalEvent,
                        MapBuilder.of(
                                "phasedRegistrationNames",
                                MapBuilder.of("bubbled", InternalAndGlobalEventPair.onPresentationModeChange.globalEvent)))
                .build();
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

}
