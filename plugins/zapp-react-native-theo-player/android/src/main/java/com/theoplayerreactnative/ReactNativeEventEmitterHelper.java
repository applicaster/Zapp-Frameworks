package com.theoplayerreactnative;

import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.theoplayer.android.api.event.EventListener;
import com.theoplayer.android.api.event.player.DurationChangeEvent;
import com.theoplayer.android.api.event.player.PlayEvent;
import com.theoplayer.android.api.event.player.PlayerEventTypes;
import com.theoplayer.android.api.event.player.TimeUpdateEvent;

import java.util.Collections;
import java.util.HashMap;
import java.util.Set;
import java.util.TreeSet;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/**
 * Helper class to handle the dynamic event registration.
 * On iOS it can happen on the emitter itself
 */
public class ReactNativeEventEmitterHelper extends ReactContextBaseJavaModule {

    //static
    public static final String RCT_MODULE_NAME = "ReactNativeEventEmitterHelper";
    private static final String TAG = ReactNativeEventEmitter.class.getSimpleName();

    private class Events {
        static final String DURATION_CHANGE = "durationchange";
        static final String TIME_UPDATE = "timeupdate";
        static final String PLAY = "play";
        //static final String PRESENTATIONMODECHANGE = "presentationmodechange";
    }

    private TheoPlayerViewManager theoPlayerViewManager;

    //event listener scheduling
    private Set<String> lateInitEventListeners = Collections.synchronizedSet(new TreeSet<String>());
    private final ScheduledExecutorService eventListenerScheduler = Executors.newScheduledThreadPool(1);
    private ScheduledFuture scheduledFutureTaskForEventRegistration;

    protected HashMap<String, EventListener> listeners = new HashMap<String, EventListener>();

    public ReactNativeEventEmitterHelper(ReactApplicationContext reactContext, TheoPlayerViewManager theoPlayerViewManager) {
        super(reactContext);
        this.theoPlayerViewManager = theoPlayerViewManager;
    }

    @Override
    public String getName() {
        return RCT_MODULE_NAME;
    }

    @ReactMethod
    public void registerListenerForEvent(final String event) {
        Log.d(TAG, "registerListenerForEvent: " + event);
        if (listeners.containsKey(event)) {
            return;
        }

        if (theoPlayerViewManager.playerView == null) {
            //if the view is null, the player is not yet ready, so store the event and reschedule the event listener registration
            lateInitEventListeners.add(event);
            scheduledFutureTaskForEventRegistration = eventListenerScheduler.schedule(new Runnable() {
                @Override
                public void run() {
                    registerListenerForEvent(event);
                }
            }, 1000, TimeUnit.MILLISECONDS);
            return;
        }

        //else
        //cancel the rescheduling
        if (scheduledFutureTaskForEventRegistration != null) {
            scheduledFutureTaskForEventRegistration.cancel(false);
            scheduledFutureTaskForEventRegistration = null;
        }

        //maybe a registration event came earlier then the reschedule timer, so make sure this also will be initialised
        if (!lateInitEventListeners.contains(event)) {
            lateInitEventListeners.add(event);
        }
        //and init the stored event listeners
        if (!lateInitEventListeners.isEmpty()) {
            for (String eventName : lateInitEventListeners) {
                initEventListener(eventName);
            }
            lateInitEventListeners.clear();
        }
    }

    private void initEventListener(String event) {
        switch (event) {
            case Events.DURATION_CHANGE :
                final EventListener durationChangeListener = new EventListener<DurationChangeEvent>() {
                    @Override
                    public void handleEvent(final DurationChangeEvent timeUpdateEvent) {
                        //emit global event
                        WritableMap eventGlobal = Arguments.createMap(); //new map, because the other one get consumed!
                        Double duration = timeUpdateEvent.getDuration();
                        if (duration != null && (duration.isNaN() || duration.isInfinite())) {
                            duration = -1.;
                        }
                        eventGlobal.putDouble("duration", duration);
                        sendEvent(getReactApplicationContext(), Events.DURATION_CHANGE, eventGlobal);
                    }
                };

                listeners.put(Events.DURATION_CHANGE, durationChangeListener);
                theoPlayerViewManager.playerView.getPlayer().addEventListener(PlayerEventTypes.DURATIONCHANGE, durationChangeListener);

                break;

            case Events.TIME_UPDATE :
                final EventListener timeUpdateChangeListener = new EventListener<TimeUpdateEvent>() {
                    @Override
                    public void handleEvent(final TimeUpdateEvent timeUpdateEvent) {
                        //emit global event
                        WritableMap eventGlobal = Arguments.createMap(); //new map, because the other one get consumed!
                        Double timeUpdate = timeUpdateEvent.getCurrentTime();
                        if (timeUpdate != null && (timeUpdate.isInfinite() || timeUpdate.isNaN())) {
                            timeUpdate = -1.;
                        }
                        eventGlobal.putDouble("currentTime", timeUpdate);
                        sendEvent(getReactApplicationContext(), Events.TIME_UPDATE, eventGlobal);
                    }
                };
                listeners.put(Events.TIME_UPDATE, timeUpdateChangeListener);
                theoPlayerViewManager.playerView.getPlayer().addEventListener(PlayerEventTypes.TIMEUPDATE, timeUpdateChangeListener);

                break;

            case Events.PLAY :
                final EventListener playListener = new EventListener<PlayEvent>() {
                    @Override
                    public void handleEvent(final PlayEvent playEvent) {
                        //emit global event
                        WritableMap eventGlobal = Arguments.createMap(); //new map, because the other one get consumed!
                        sendEvent(getReactApplicationContext(), Events.PLAY, eventGlobal);
                    }
                };
                listeners.put(Events.PLAY, playListener);
                theoPlayerViewManager.playerView.getPlayer().addEventListener(PlayerEventTypes.PLAY, playListener);

                break;

            // case Events.PRESENTATIONMODECHANGE :
            //     final EventListener playListener2 = new EventListener<PresentationModeChange>() {
            //         @Override
            //         public void handleEvent(final PresentationModeChange playEvent) {
            //             //emit global event
            //             WritableMap eventGlobal = Arguments.createMap(); //new map, because the other one get consumed!
            //             eventGlobal.putBoolean("isFullScreen", theoPlayerViewManager.playerView.getFullScreenManager().isFullScreen());
            //             sendEvent(getReactApplicationContext(), Events.PRESENTATIONMODECHANGE, eventGlobal);
            //         }
            //     };
            //     listeners.put(Events.PRESENTATIONMODECHANGE, playListener2);
            //     theoPlayerViewManager.playerView.getPlayer().addEventListener(PlayerEventTypes.PRESENTATIONMODECHANGE, playListener2);

            //     break;
            default:
                break;
        }
    }


    //emit
    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @androidx.annotation.Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }


}
