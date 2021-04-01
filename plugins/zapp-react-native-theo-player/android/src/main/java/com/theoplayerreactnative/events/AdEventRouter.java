package com.theoplayerreactnative.events;

import android.view.View;

import com.applicaster.util.APLogger;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.theoplayer.android.api.ads.Ads;
import com.theoplayer.android.api.event.EventListener;
import com.theoplayer.android.api.event.EventType;
import com.theoplayer.android.api.event.ads.AdEvent;
import com.theoplayer.android.api.player.Player;
import com.theoplayerreactnative.TheoPlayerViewManager;

import org.jetbrains.annotations.NotNull;

public class AdEventRouter<T extends AdEvent<T>> implements IEvenRouter<T> {

    private static final String TAG = TheoPlayerViewManager.TAG;

    public interface EventCast<E extends AdEvent<E>> {
        WritableMap toRN(E event);
    }

    public AdEventRouter(EventType<T> type, EventCast<T> cast) {
        this.cast = cast;
        this.type = type;
    }

    public void subscribe(@NotNull Player player,
                          @NotNull View playerView,
                          @NotNull ThemedReactContext reactContext,
                          @NotNull String internalEvent) {

        Ads ads = player.getAds();
        if(null == ads)
            return;

        EventListener<T> eventListener = e -> {
            APLogger.verbose(TAG, "Received player ad event " + type.getName());
            WritableMap event = cast.toRN(e);
            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                    playerView.getId(),
                    internalEvent,
                    event);
        };

        playerView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener(){

            @Override
            public void onViewAttachedToWindow(View v) {}

            @Override
            public void onViewDetachedFromWindow(View v) {
                ads.removeEventListener(type, eventListener);
            }
        });

        ads.addEventListener(type, eventListener);
    }

    private final EventCast<T> cast;
    private final EventType<T> type;

}
